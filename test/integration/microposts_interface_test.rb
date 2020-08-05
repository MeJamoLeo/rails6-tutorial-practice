require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination' # ページネーションが存在しているか確認
    assert_select 'input[type=file]'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      # 空送信した際にマイクロポストの数が変わらないことを確認する
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
    # 有効な送信
    content = "This micropost really ties the room together"
    image = fixture_file_upload('test/fixtures/kitten.jpg', "image/jpeg")
    assert_difference 'Micropost.count', 1 do
      # 有効な送信をした際にマイクロポストの数が1つ増える
      post microposts_path, params: {
          micropost: {
              content: content,
              image: image
            }
        }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  # サイドバーでマイクロポストの投稿数をテストするためのテンプレート
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match("#{@user.microposts.count} microposts", response.body)
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match("0 microposts", response.body)
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match("1 micropost", response.body)
  end
end