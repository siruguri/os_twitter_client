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

    it 'works with valid actions' do
      data = nil
      assert_enqueued_with(job: TwitterFetcherJob) do
        data = Ajax::Library.route_action("actions/trigger/1", users(:user_2))
      end
      
      assert_is_success data
      # handle of one of user_2's friends
      assert_match /leader_profile_handle/, data[:data]

      assert_enqueued_with(job: TwitterFetcherJob) do
        data = Ajax::Library.route_action("actions/trigger/2/" + ({tweet_id: 12380912039}.to_json), users(:user_2))
      end
      assert_match /scheduled/, data[:data]

      # search for retweets
      # until such time as I patch the fixtures gem
      tweetid = 12380912039

      RetweetRecord.all.map &:delete; r = RetweetRecord.new(tweet_id: tweetid, user_id: users(:user_2).id); r.save
      data = Ajax::Library.route_action("actions/execute/3/[#{tweetid}]", users(:user_2))
      RetweetRecord.all.map &:delete      
      assert_equal 1, data[:data].size
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

