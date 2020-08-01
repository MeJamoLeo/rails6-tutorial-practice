require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # users.ymlからテストユーザーのデータを用意する
  def setup
    @user = users(:michael)
  end

  # 無効な情報を送信した際に，編集フォームに戻るかをテスト
    # 1.編集ページに移行する（テンプレートの確認）
    # 2.パラメータを投げる
    # 3.編集ページに戻る
    # 4.エラーメッセージの確認（演習）
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: "",
        email: "user@invalid",
        password: "foo",
        password_confirmation: "bar"
      }
    }
    assert_template 'users/edit'
    assert_select 'div.alert'
  end

  # 編集の成功のテスト
    # 1．編集ページに移動（テンプレートの確認）
    # 2．パラメータを投げる
    # 3．成功のフラッシュメッセージが出る
    # 4．ユーザーのページにリダイレクト
    # 5．データの検証
  test "successful edit" do
    # ユーザーフレンドリー
    get edit_user_path(@user)
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    assert_nil session[:forwarding_url]
    assert_redirected_to edit_user_url(@user) # ログインしたら，編集ページに戻る

    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: "",
        password_confirmation: ""
      }
    }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

end
