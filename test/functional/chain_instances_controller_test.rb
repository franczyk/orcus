require 'test_helper'

class ChainInstancesControllerTest < ActionController::TestCase
  setup do
    @chain_instance = chain_instances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:chain_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create chain_instance" do
    assert_difference('ChainInstance.count') do
      post :create, :chain_instance => @chain_instance.attributes
    end

    assert_redirected_to chain_instance_path(assigns(:chain_instance))
  end

  test "should show chain_instance" do
    get :show, :id => @chain_instance.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @chain_instance.to_param
    assert_response :success
  end

  test "should update chain_instance" do
    put :update, :id => @chain_instance.to_param, :chain_instance => @chain_instance.attributes
    assert_redirected_to chain_instance_path(assigns(:chain_instance))
  end

  test "should destroy chain_instance" do
    assert_difference('ChainInstance.count', -1) do
      delete :destroy, :id => @chain_instance.to_param
    end

    assert_redirected_to chain_instances_path
  end
end
