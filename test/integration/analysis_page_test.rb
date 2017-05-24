require 'test_helper'

class AnalysisPageTest < Capybara::Rails::TestCase
  def setup
    Capybara.default_driver = :webkit
    visit '/twitter/analysis/' + twitter_profiles(:twitter_profile_1).handle
  end
  
  test 'actions work' do
    find('button#older').click
    refute_match /no such action/i, page.body
    assert_match /started older tweets/i, page.body
  end
end
