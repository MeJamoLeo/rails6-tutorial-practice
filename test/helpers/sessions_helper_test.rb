require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

    def setup
    @user = users(:michael)
    remember(@user)
    end

    # current_userはセッションがnilの場合に正しいユーザを返す
    test "current_user return right user when session is nil " do
        # assert_equal(期待する値，実際の値)
        # assert_equal (current_user, @user) でも可能
        assert_equal(@user, current_user)
        assert is_logged_in?
    end

    # current_userは、記憶しているダイジェストが間違っている場合にnilを返します。
    test "current_user returns nil when remember digest is wrong" do
        @user.update_attribute(:remember_digest, User.digest(User.new_token))
        assert_nil current_user
    end
end