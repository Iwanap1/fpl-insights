require "test_helper"

class FixturesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fixtures_index_url
    assert_response :success
  end
end
