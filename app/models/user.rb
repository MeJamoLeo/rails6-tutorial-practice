class User < ApplicationRecord
    # Micropostとの関連付けを行っています
    has_many :microposts, dependent: :destroy
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
