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
    refute page.has_css?('.overlay-grayout #retweet', visible: true)    
    assert_equal tweets, page.all('.action-button#retweet-dialog').size
    
    page.all('.item')[0].find('.action-button#retweet-dialog').click

    # Opens overlay
    assert page.has_css?('.overlay-grayout #retweet', visible: true)
    rt_button = page.find('.overlay-grayout #retweet')
    # Sets data

    assert_equal page.all('.item')[0]['id'], rt_button['data-node-ref']
    assert_match /tweet\-/, rt_button['data-node-ref']
    
    rt_button.click
    sleep 1
    assert_match /disabled/, page.all('.item').first[:class]
  end
end
