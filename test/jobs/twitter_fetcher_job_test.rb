require 'test_helper'
class TwitterFetcherJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    set_net_stubs
  end

  test 'other jobs' do
    TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'tweet', text: 'my tweeting now'
    TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'my_friends'
  end

  test 'retweeting' do
    assert_difference('RetweetRecord.count', 1) do
      TwitterFetcherJob.perform_now(
        twitter_profiles(:twitter_profile_1), 'retweet', tweet_id: 12341345
      )
    end
  end
  
  test ':bio job works with valid handle' do
    refute_match /Oakland/, twitter_profiles(:twitter_profile_1).location
    TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1)
    assert_match /Oakland/, twitter_profiles(:twitter_profile_1).location    
  end

  test 'job fails gracefully with invalid handle' do
    TwitterFetcherJob.perform_now twitter_profiles(:nota_twitter_profile)

    refute TwitterRequestRecord.last.status?
  end

  describe ":tweets job" do
    it 'works when profile has twitter id' do
      assert_difference('Tweet.count', 3) do
        TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'tweets'
      end

      assert_equal twitter_profiles(:twitter_profile_1).id, Tweet.last.user.id
      assert_equal 1111911239413, Tweet.last.tweet_id
    end

    it 'works when profile does not have twitter id' do
      assert_difference('Tweet.count', 4) do
        TwitterFetcherJob.perform_now twitter_profiles(:no_id_profile), 'tweets'
      end
      assert_equal 239413592287818484, Tweet.last.tweet_id      
    end

    it 'tramples bookmark' do
      key = "#{users(:user_1)&.email}.twitter.bookmark"
      c = Config.find_or_create_by config_key: key, config_value: '13'
      TwitterFetcherJob.perform_now twitter_profiles(:no_id_profile), 'tweets', refresh_bookmark: key
      assert_equal '1', Config.find_by_config_key(key).config_value
    end
  end

  test 'follower bios' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      TwitterFetcherJob.perform_now twitter_profiles(:leader_profile), 'follower_bios'
    end

    assert_equal twitter_profiles(:leader_profile).graph_connections_head.count,
                 enqueued_jobs.size
  end
    
  describe ":followers" do
    it 'works without existing followers' do
      assert_difference('TwitterProfile.count', 2) do
        TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'followers'
      end
      t = TwitterProfile.last
      assert_equal 8400, t.twitter_id
      
      assert_equal 2, GraphConnection.where(leader: twitter_profiles(:twitter_profile_1)).count

      assert_equal 1479414865424994218, TwitterRequestRecord.last.cursor
      assert_equal "follower_ids", TwitterRequestRecord.last.request_type
    end
    
    it 'works with existing followers' do
      assert_equal 1, GraphConnection.where(leader_id: twitter_profiles(:existing_followers).id,
                                            follower_id: twitter_profiles(:just_follower_1).id).count

      prev_q_size = enqueued_jobs.size
      assert_difference('TwitterProfile.count', 3) do
        TwitterFetcherJob.perform_now twitter_profiles(:existing_followers), 'followers'
      end

      # new followers will get new follower_bios jobs
      assert_equal 1 + prev_q_size, enqueued_jobs.size
      assert_equal 0, GraphConnection.where(follower_id: TwitterProfile.find_by_handle('just_follower_1').id).count
    end
  end
end
