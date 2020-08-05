require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # user_idは有効である必要がある
  test "should be valid" do
    assert @micropost.valid?
  end

  # user_idは存在する必要がある
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # contentは空白であってはならない
  test "content should be present" do
    @micropost.content=" "
    assert_not @micropost.valid?
  end

  # contentは140文字を超えてはならない
  test "content should be at most 140 characters" do
    @micropost.content="a" * 141
    assert_not @micropost.valid?
  end

  # 更新日が最新のポストを最初にし，順番に並べる
  test 'order should be most recent first' do
    # 「Micropostsの最新ポスト」と「Micropost.first」が同じポストか確認する．
    assert_equal microposts(:most_recent), Micropost.first
  end
end