require 'test_helper'

class PoolsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pools)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pool" do
    assert_difference('Pool.count') do
      post :create, :pool => { }
    end

    assert_redirected_to pool_path(assigns(:pool))
  end

  test "should show pool" do
    get :show, :id => pools(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pools(:one).to_param
    assert_response :success
  end

  test "should update pool" do
    put :update, :id => pools(:one).to_param, :pool => { }
    assert_redirected_to pool_path(assigns(:pool))
  end

  test "should destroy pool" do
    assert_difference('Pool.count', -1) do
      delete :destroy, :id => pools(:one).to_param
    end

    assert_redirected_to pools_path
  end
end
