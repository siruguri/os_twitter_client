require 'test_helper'

class UserSignupTest < Capybara::Rails::TestCase
  include Rack::Test::Methods
  def setup
    Capybara.default_driver = :webkit
  end
  
  test 'is redirected to twitter page' do
    visit '/users/sign_up'
    page.fill_in  'user[email]', with: 'newemail@new.com'
    page.fill_in  'user[password]', with: 'password123'
    page.fill_in  'user[password_confirmation]', with: 'password123'

    page.click_on 'Sign up'
    assert_equal twitter_input_handle_path, page.current_path
  end
end
