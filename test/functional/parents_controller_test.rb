require 'test_helper'

class ParentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create parent" do
    assert_difference('Parent.count') do
      post :create, :parent => { }
    end

    assert_redirected_to parent_path(assigns(:parent))
  end

  test "should show parent" do
    get :show, :id => parents(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => parents(:one).to_param
    assert_response :success
  end

  test "should update parent" do
    put :update, :id => parents(:one).to_param, :parent => { }
    assert_redirected_to parent_path(assigns(:parent))
  end

  test "should destroy parent" do
    assert_difference('Parent.count', -1) do
      delete :destroy, :id => parents(:one).to_param
    end

    assert_redirected_to parents_path
  end
end
