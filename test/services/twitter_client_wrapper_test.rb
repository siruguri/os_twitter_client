require 'test_helper'

class TwitterClientWrapperTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  def setup
    set_net_stubs
    @c = TwitterClientWrapper.new
    @handle = twitter_profiles :twitter_profile_1
  end

  test 'retweeting works' do
    h = @handle
    @c.rate_limited do
      retweet! h, {tweet_id: 12341345}
    end
  end
  
  describe 'rate limiting works' do
    it 'works in general' do
      now = Time.now
      (1..13).each do |t|
        h = @handle
        @c.rate_limited('bio') do
          fetch_profile! h
        end
      end

      # That should have set off the rate limiting exactly once.
      assert_equal 1, TwitterRequestRecord.where('created_at >= ? and ran_limit = ?', now, true).count
    end
    it 'works for followers at rate of 1/min' do
      now = Time.now
      (1..2).each do |t|
        h = @handle
        @c.rate_limited('followers') do
          fetch_profile! h
        end
      end

      # That should have set off the rate limiting exactly once.
      assert_equal 1, TwitterRequestRecord.where('created_at >= ? and ran_limit = ?', now, true).count
    end
  end    

  describe "fetching tweets" do
    it 'works when tweet has retweet' do
      assert_difference('TwitterProfile.count') do
        @c.rate_limited do
          fetch_status!({tweet_id: 'tweetistherethathasretweet'})
        end
      end
      assert Tweet.last.is_retweeted      
    end
    
    it 'works when tweet is original' do
      assert_difference('TwitterProfile.count') do
        @c.rate_limited do
          fetch_status!({tweet_id: 'tweetisthere'})
        end

        refute Tweet.last.is_retweeted
      end
    end
  end
  
  test 'followers' do
    h = @handle
    @c.rate_limited do
      fetch_followers! h
    end
    assert_equal 2, GraphConnection.where(leader_id: @handle.id).count
    # This Twitter ID is in the fixture file
    assert_equal 1, TwitterProfile.where(twitter_id: 8400).count
  end
  
  describe 'my feed' do
    it 'works without a prev request' do
      h = @handle

      # some_other_leader remains, but leader_profile is gone - so total connections for @handle's friends
      # remains at 2
      refute_difference('GraphConnection.where(follower_id: @handle.id).count') do
        @c.rate_limited do
          fetch_my_friends! h
        end
      end

      # This Twitter ID is in the fixture file
      assert_equal 1, TwitterProfile.where(twitter_id: 8401).count
      assert_equal false, TwitterProfile.where(twitter_id: 8401).first.protected
    end

    it 'works with a previous request' do
      h = @handle
      TwitterRequestRecord.create handle: h.handle, request_type: 'following_ids', cursor: 12345

      # Get four, lose two
      assert_difference('GraphConnection.where(follower_id: @handle.id).count', 2) do
        @c.rate_limited do
          fetch_my_friends! h
        end
      end

      # This Twitter ID is in the fixture file
      assert_equal 1, TwitterProfile.where(twitter_id: 8401).count
    end
  end

  describe 'profile fetching' do
    it 'works with a new profile' do
      h = @handle
      @c.rate_limited do
        fetch_profile! h
      end

      # See test/fixtures/files/twitter_profile_array.json for these data
      @handle.reload
      assert_equal DateTime.strptime("Fri Nov 06 20:58:24 +0000 2015", '%a %b %d %H:%M:%S %z %Y'),                   
                   twitter_profiles(:twitter_profile_1).last_tweet_time
      assert_equal 4242, twitter_profiles(:twitter_profile_1).tweets_count
      assert_equal 143916, twitter_profiles(:twitter_profile_1).num_followers
      assert_equal 145, twitter_profiles(:twitter_profile_1).num_following
      assert_match /allafarce/, @handle.last_tweet
    end

    it 'ignores a fresh profile' do
      @handle.bio = 'got a bio'
      @handle.save
      original = @handle.last_tweet
      
      h = @handle
      @c.rate_limited do
        fetch_profile! h
      end

      @handle.reload
      assert_equal original, @handle.last_tweet
    end
  end
  
  describe 'plain tweets fetching' do
    it 'works without pagination' do
      wa_ct = WebArticle.count
      assert_difference('Tweet.count', 2) do
        h = twitter_profiles :bobcostas
        # Bob has a dummy tweet
        @c.rate_limited do
          fetch_tweets! h, relative_id: -1
        end
      end

      assert_equal false, Tweet.order(created_at: :desc).first.processed
      assert_equal 2 + wa_ct, WebArticle.count
      assert_equal 'twitter', WebArticle.last.source

      # There's one scraper job for the full list of articles and none for the pagination
      assert_equal 0, enqueued_jobs.select { |j| j[:job] == TwitterRedirectFetchJob }.size
      assert_equal 0, enqueued_jobs.select { |j| j[:job] == TwitterFetcherJob }.size

      assert_equal Tweet.last.user.id, WebArticle.last.twitter_profile_id
      refute Tweet.last.mesg.blank?
      assert Tweet.last.is_retweet?
    end

    it 'works with pagination to get latest tweets' do
      assert_difference('Tweet.count', 2) do
        h = twitter_profiles :bobcostas
        # Bob has a dummy tweet
        @c.rate_limited do
          fetch_tweets! h, relative_id: -1, pagination: true
        end
      end

      assert_equal 'twitter', WebArticle.last.source

      # There's one scraper job for the full list of articles and one for the pagination
      assert_equal 0, enqueued_jobs.select { |j| j[:job] == TwitterRedirectFetchJob }.size
      assert_equal 1, enqueued_jobs.select { |j| j[:job] == TwitterFetcherJob }.size
    end

    it 'works with pagination to get range' do
      assert_difference('Tweet.count', 2) do
        h = twitter_profiles :bobcostas
        # Bob has a dummy tweet
        @c.rate_limited do
          # older than 712.., newer than 9987...
          fetch_tweets! h, direction: :older, relative_id: 71209123, since_id: 9987123, pagination: true
        end
      end

      assert_equal 'twitter', WebArticle.last.source

      # There's one scraper job for the full list of articles and one for the pagination
      assert_equal 0, enqueued_jobs.select { |j| j[:job] == TwitterRedirectFetchJob }.size
      assert_equal 1, enqueued_jobs.select { |j| j[:job] == TwitterFetcherJob }.size
    end
  end

  test 'plain tweets fetching with a relative_id' do
    assert_difference('Tweet.count', 1) do
      h = @handle
      @c.rate_limited do
        fetch_tweets! h, relative_id: '567r', direction: :newer
      end
    end
  end

end

