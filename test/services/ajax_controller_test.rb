require 'test_helper'
class AjaxLibraryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
  end
    
  describe 'general multiplex' do
    it 'handles errors gracefully' do
      data = Ajax::Library.route_action("actions/trigger/")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/-1")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/a")
      assert_has_error data, 422

      # needs user for some actions
      data = Ajax::Library.route_action("actions/trigger/1")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/3")
      assert_has_error data, 422
    end

    describe 'valid actions: ' do
      it 'case 1 is valid' do
        data = nil
        assert_enqueued_with(job: TwitterFetcherJob) do
          data = Ajax::Library.route_action("actions/trigger/1", users(:user_2))
        end
        
        assert_is_success data
        # handle of one of user_2's friends
        assert_match /leader_profile_handle/, data[:data]
      end
      describe 'case 2: ' do
        it 'is valid without quote' do
          data = nil
          assert_enqueued_with(job: TwitterFetcherJob) do
            data = Ajax::Library.route_action("actions/trigger/2/" + ({tweet_id: 12380912039}.to_json), users(:user_2))
          end
          assert_match /scheduled/, data[:data]
        end
        it 'is valid with quote but requires tweet' do
          data = nil
          assert_no_enqueued_jobs(only: TwitterFetcherJob) do
            data = Ajax::Library.route_action("actions/trigger/2/" + ({tweet_id: 12380912039, quote: "quote me"}.to_json),
                                              users(:user_2))
          end
          Tweet.create tweet_id: 12380912039, user: users(:user_with_profile).twitter_profile
          assert_enqueued_with(job: TwitterFetcherJob) do
            data = Ajax::Library.route_action("actions/trigger/2/" + ({tweet_id: 12380912039, quote: "quote me"}.to_json),
                                              users(:user_2))
          end
          assert_match /scheduled/, data[:data]
        end
      end

      it 'case 3 is valid' do
        # search for retweets
        # until such time as I patch the fixtures gem
        tweetid = 12380912039

        RetweetRecord.all.map &:delete; r = RetweetRecord.new(tweet_id: tweetid, user_id: users(:user_2).id); r.save
        data = Ajax::Library.route_action("actions/execute/3/[#{tweetid}]", users(:user_2))
        RetweetRecord.all.map &:delete      
        assert_equal 1, data[:data][:data].size
      end
    end
  end
  
  private
  def assert_has_error(data, code = 500)
    data[:status] == 'error' and data[:code] == code
  end
  def assert_is_success(data)
    data[:status] == 'success' and data[:code] == '200'
  end
end

