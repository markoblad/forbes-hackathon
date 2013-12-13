require 'test_helper'

class ForbesUsersControllerTest < ActionController::TestCase
  setup do
    @forbes_user = forbes_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:forbes_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create forbes_user" do
    assert_difference('ForbesUser.count') do
      post :create, forbes_user: { linkedin: @forbes_user.linkedin, username: @forbes_user.username }
    end

    assert_redirected_to forbes_user_path(assigns(:forbes_user))
  end

  test "should show forbes_user" do
    get :show, id: @forbes_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @forbes_user
    assert_response :success
  end

  test "should update forbes_user" do
    put :update, id: @forbes_user, forbes_user: { linkedin: @forbes_user.linkedin, username: @forbes_user.username }
    assert_redirected_to forbes_user_path(assigns(:forbes_user))
  end

  test "should destroy forbes_user" do
    assert_difference('ForbesUser.count', -1) do
      delete :destroy, id: @forbes_user
    end

    assert_redirected_to forbes_users_path
  end
end
