require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  # プロフィールの見た目をテストする
    # プロフィールページにget
    # テンプレートの確認
    # 要素の確認
      # ページのタイトル
      # h1にユーザーの名前
      # gravatarがあるか
      # paginationが存在するか
  test "profile display" do
    # micropost.ymlにcreate_atなどを定義している
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar' # h1タグの中にあるimgタグ
    assert_match(@user.microposts.count.to_s, response.body) #ユーザーのマイクロポストの数とレスポンスのボディの数？が等しいか？
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end