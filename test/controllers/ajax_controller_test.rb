require 'test_helper'

class AjaxControllerTest < ActionController::TestCase
  test 'routing' do
    assert_routing ({path: '/ajax_api', method: :post}), {controller: 'ajax', action: 'multiplex'}
  end
  
  test '#multiplex:errors' do
    post :multiplex, xhr: true, params: {payload: "actions/trigger/a"}
    assert_equal 'error', JSON.parse(response.body)['status']
    post :multiplex, xhr: true, params: {payload: "actionsx/trigger/1"}
    assert_equal 'error', JSON.parse(response.body)['status']
    
    post :multiplex, params: {payload: "actionsx/trigger/1"}    
    assert_equal ({}), JSON.parse(response.body)
    post :multiplex, xhr: true, params: {payload: "reads/trigger/1"}
    assert_equal 200, response.status
  end

  test '#multiplex:success' do
    sign_in users(:user_2)
    post :multiplex, xhr: true, params: {payload: "actions/trigger/1"}
    assert_equal 'success', JSON.parse(response.body)['status']
  end    
end
