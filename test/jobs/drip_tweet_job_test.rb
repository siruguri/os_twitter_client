require 'test_helper'

class DripTweetJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    set_net_stubs
  end
  
  test 'job sets up job if there is work to do' do
    assert_enqueued_with(job: DripTweetJob) do
      DripTweetJob.perform_now(twitter_profiles(:twitter_profile_1), ['my tweet a', 'my tweet b', 'my tweet c'],
                               token: users(:user_with_profile).latest_token_hash)
    end
    # The array is shifted by 1 
    assert_equal 2, enqueued_jobs[0][:args][1].length
  end
  test 'job does not sets up job when there is no work to do' do
    assert_no_enqueued_jobs do
      DripTweetJob.perform_now(twitter_profiles(:twitter_profile_1), ['my tweet a'],
                               token: users(:user_with_profile).latest_token_hash
                              )
    end
  end
end
