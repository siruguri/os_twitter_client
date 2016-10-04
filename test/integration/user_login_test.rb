require 'test_helper'

class UserLoginTest < Capybara::Rails::TestCase
  include Rack::Test::Methods
  def setup
    Capybara.default_driver = :webkit
  end
  
  test 'can see tags list' do
    visit '/users/sign_in'
    page.fill_in  'user[email]', with: users(:user_2).email
    page.fill_in  'user[password]', with: 'password'
    
    page.click_on 'Log in'
    assert_equal twitter_input_handle_path, page.current_path
  end
end
