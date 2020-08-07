class User < ApplicationRecord
    has_many :microposts, dependent: :destroy# Micropostとの関連付けを行っています
    has_many :active_relationships, class_name: "Relationship",foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower

    attr_accessor :remember_token, :activation_token

    # before_save :downcase_email
    before_save {email.downcase!}
    before_create :create_activation_digest # createアクションの前に行う

    # before_save {self.email = email.downcase}
    validates(:name, presence: true, length: {maximum: 50})
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates(:email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
            )
    # password がからの場合は例外として許す
    validates(:password, presence: true,length: {minimum: 6}, allow_nil: true)
    has_secure_password

    # 渡された文字列のハッシュ値を返す
    def User.digest(string)
        # ここどうなってるんかわからん
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    def remember
        # new_tokenで取得したトークンserのremember_token属性にいれる
        self.remember_token = User.new_token
        # ダイジェストした値をデータベースに記録する？
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す．
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # ユーザーのログイン情報を破棄す
    def forget
        # 記憶ダイジェストをnilで更新する
        update_attribute(:remember_digest, nil)
    end

    def user_params
        params.require(:user).permit(:name,:email,:password, :password_confirmation)
    end

    # 試作feedの定義
    # 完全な実装は次章の「ユーザーをフォローする」を参照
    def feed
        Micropost.where("user_id = ?", id)
    end

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # ユーザーのステータスフィードを返す
    def feed
    following_ids = "SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                        OR user_id = :user_id", user_id: id)

        # メソッド内変数にキーと値のペアを用いる
#            Micropost.where(
#                "user_id in (:following_ids) or user_id = :user_id",
#                following_ids: following_ids, user_id: id
#            )

        # 自分自身の投稿を除いた場合
            # Micropost.where("user_id IN (?)", following_ids)
    end

    # ユーザーをフォローする
    def follow(other_user)
        following<< other_user
        # followingは3行目あたりで定義している
        # 配列のように扱うことができる
        # << は　配列の最後に追加できる書き方
    end

    # ユーザーをフォロー解除する
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end

    # 現在のユーザーがフォローしていたらtrueを返す
    def following?(other_user)
        following.include?(other_user)
    end


    private

    # emailを全て小文字にする
    # before_save {email.downcase!} を使うのでコメントアウト
            # def downcase_email
            #     self.email = email.downcase
            # end

    # 有効化トークンとダイジェストを作成及び代入する
    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end
