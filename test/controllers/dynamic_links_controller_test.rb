require "test_helper"

class DynamicLinksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dynamic_links_index_url
    assert_response :success
  end

  test "should get show" do
    get dynamic_links_show_url
    assert_response :success
  end

  test "should get new" do
    get dynamic_links_new_url
    assert_response :success
  end

  test "should get create" do
    get dynamic_links_create_url
    assert_response :success
  end

  test "should get edit" do
    get dynamic_links_edit_url
    assert_response :success
  end

  test "should get update" do
    get dynamic_links_update_url
    assert_response :success
  end

  test "should get destroy" do
    get dynamic_links_destroy_url
    assert_response :success
  end

  test "should get analytics" do
    get dynamic_links_analytics_url
    assert_response :success
  end

  test "should get toggle_active" do
    get dynamic_links_toggle_active_url
    assert_response :success
  end
end
