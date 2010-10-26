require 'test_helper'

class HostPoolmapsControllerTest < ActionController::TestCase
  setup do
    @host_poolmap = host_poolmaps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:host_poolmaps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create host_poolmap" do
    assert_difference('HostPoolmap.count') do
      post :create, :host_poolmap => @host_poolmap.attributes
    end

    assert_redirected_to host_poolmap_path(assigns(:host_poolmap))
  end

  test "should show host_poolmap" do
    get :show, :id => @host_poolmap.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @host_poolmap.to_param
    assert_response :success
  end

  test "should update host_poolmap" do
    put :update, :id => @host_poolmap.to_param, :host_poolmap => @host_poolmap.attributes
    assert_redirected_to host_poolmap_path(assigns(:host_poolmap))
  end

  test "should destroy host_poolmap" do
    assert_difference('HostPoolmap.count', -1) do
      delete :destroy, :id => @host_poolmap.to_param
    end

    assert_redirected_to host_poolmaps_path
  end
end
