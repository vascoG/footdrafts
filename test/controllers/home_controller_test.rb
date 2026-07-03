require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get root page" do
    get root_url
    assert_response :success
    assert_includes response.body, 'id="footdrafts-app"'
  end
end
