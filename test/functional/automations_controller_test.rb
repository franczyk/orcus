require 'test_helper'

class AutomationsControllerTest < ActionController::TestCase
  setup do
    @automation = automations(:one)
  end

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
      post :create, :automation => @automation.attributes
    end

    assert_redirected_to automation_path(assigns(:automation))
  end

  test "should show automation" do
    get :show, :id => @automation.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @automation.to_param
    assert_response :success
  end

  test "should update automation" do
    put :update, :id => @automation.to_param, :automation => @automation.attributes
    assert_redirected_to automation_path(assigns(:automation))
  end

  test "should destroy automation" do
    assert_difference('Automation.count', -1) do
      delete :destroy, :id => @automation.to_param
    end

    assert_redirected_to automations_path
  end
end
