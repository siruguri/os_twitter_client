require 'test_helper'

class RedirectMapsControllerTest < ActionController::TestCase
  def setup
    @map = redirect_maps(:one)
  end
  
  test 'getting a redirect updates the DB' do
    assert_difference('RedirectRequest.count', 1) do
      get :show, params: {id: @map.src}
    end
    
    assert_redirected_to @map.dest

    req = RedirectRequest.last
    assert_equal 'Rails Testing', req.request_agent
  end
end
