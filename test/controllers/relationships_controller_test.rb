require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # フォローする時にはユーザーはログインする必要がある
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  # フォロー解除するにはユーザーはログインしている必要がある
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end

end
