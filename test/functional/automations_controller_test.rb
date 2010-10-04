require 'test_helper'

class AutomationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:automations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create automation" do
    assert_difference('Automation.count') do
      post :create, :automation => { }
    end

    assert_redirected_to automation_path(assigns(:automation))
  end

  test "should show automation" do
    get :show, :id => automations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => automations(:one).to_param
    assert_response :success
  end

  test "should update automation" do
    put :update, :id => automations(:one).to_param, :automation => { }
    assert_redirected_to automation_path(assigns(:automation))
  end

  test "should destroy automation" do
    assert_difference('Automation.count', -1) do
      delete :destroy, :id => automations(:one).to_param
    end

    assert_redirected_to automations_path
  end
end
