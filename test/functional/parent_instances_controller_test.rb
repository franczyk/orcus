require 'test_helper'

class ParentInstancesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parent_instances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create parent_instance" do
    assert_difference('ParentInstance.count') do
      post :create, :parent_instance => { }
    end

    assert_redirected_to parent_instance_path(assigns(:parent_instance))
  end

  test "should show parent_instance" do
    get :show, :id => parent_instances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => parent_instances(:one).to_param
    assert_response :success
  end

  test "should update parent_instance" do
    put :update, :id => parent_instances(:one).to_param, :parent_instance => { }
    assert_redirected_to parent_instance_path(assigns(:parent_instance))
  end

  test "should destroy parent_instance" do
    assert_difference('ParentInstance.count', -1) do
      delete :destroy, :id => parent_instances(:one).to_param
    end

    assert_redirected_to parent_instances_path
  end
end
