module SessionsHelper
    def log_in(user)
        session[:user_id] = user.id
    end

    # ユーザーのセッションを永続的にする
    def remember(user)
        # データベースのremember_digestをいれる
        user.remember
        # 永続化・暗号化済みのuser.idとuser.remember_tokenを入れる．
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # remember_tokenのcookieに対応するユーザーを返す．
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: session[:user_id])
        elsif (user_id = cookies.signed[:user_id])
            # raise # テストがパスすれば，この部分がテストされていないことがわかる．
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # 渡されたユーザーがカレントユーザーであればtrue
    def current_user?(user)
        user && user == current_user
    end


    def logged_in?
        !current_user.nil?
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end


    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    # 記憶したURL（もしくはデフォルト値）にリダイレクト
        # セッションに保持した
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url) # 次回のログインで保護されたページに転送されてしまう
    end

    # アクセスしようとしたURLを覚えておく
        # もしリクエストがgetだった場合，もとのurlをセッションに保持しておく？
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end
end