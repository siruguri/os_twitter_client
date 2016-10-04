require 'test_helper'

class RetweetButtonTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper
  include Warden::Test::Helpers
  Warden.test_mode!
  
  def setup
    Capybara.current_driver = :webkit
    login_as users(:user_2), scope: :user
    visit '/twitter/feed'

    @tp = users(:user_2).twitter_profile
  end
  
  test 'retweeting' do
    tweets = @tp.friends.inject(0) do |sum, f|
      sum += f.tweets.count
    end
    
    assert_equal tweets, page.all('.retweet-button').size
    page.all('.retweet-button').first.click
    #assert_match /disabled/, page.all('.retweet-button').first[:class]
  end
end
