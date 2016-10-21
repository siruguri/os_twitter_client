require 'test_helper'

class TwitterJobsTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper

  def setup
    Capybara.current_driver = :rack_test
    visit '/twitter/input_handle'
  end
  
  test 'Followers job can be started' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      fill_in 'twitter-handle', with: 'bobcostas'
      click_button 'Populate followers'
    end

    assert_equal 'bobcostas', GlobalID::Locator.locate(enqueued_jobs[0][:args][0]['_aj_globalid']).handle
  end

  test 'uncrawled profiles processing can be started' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      click_button 'no-tweet-profiles'
    end

    # Twice as many twitter_profiles that don't have tweets - right now, 7
    # added twitter_profile_user_with_profile on 9/8
    # added tp_assign_to_2 on 9/23
    # added 3 more on 10/20
    assert_equal 2 * 11, enqueued_jobs.size
  end
end
