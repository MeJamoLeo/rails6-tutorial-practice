require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with valid information followed by logout" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: {
      session:{
        email: @user.email,
        password: 'password'
      }
    }
    assert is_logged_in?
    # リダイレクト先が正しいかどうかをチェックする
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # ログアウトの処理
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシュミレートする
    delete logout_path
    # ログアウトの処理（続き）
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0

  end

  test "login with valid email/invalid password" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params:{
      session:{
        email:@user.email,
        password:"invalid"
        }
      }
    assert_template 'sessions/new'
    # フラッシュが表示されているか？
    assert_not flash.empty?
    get root_path
    # homeに戻って,フラッシュが表示されていないか？
    assert flash.empty?
  end

  # ダイジェストが存在しない場合のテスト
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

  # リメンバーにチェックが入っている場合のテスト
  test "login with remembering" do
    log_in_as(@user,remember_me:'1')
    delete logout_path
  end

  # リメンバーにチェックが入っていない場合のテスト
  test "login without remembering" do
    # cookieを保持してログイン
    log_in_as(@user,remember_me:'1')
    delete logout_path

    # cookieを削除してログイン
    post login_path, params: {
      session:{
        email: @user.email,
        password: 'password',
        remember_me: '0'
      }
    }
    # log_in_as(@user,remember_me:'0')
    assert_empty cookies[:remember_token]
  end
end
