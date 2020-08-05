class ApplicationController < ActionController::Base
    include SessionsHelper

        private
        # beforeアクション
        # ログイン済みのユーザーかどうか確認する
            def logged_in_user
                unless logged_in? # もしログイン状態ではない場合，
                    store_location  # セッションにurlを保持しておく
                    flash[:danger] = "Please log in."
                    redirect_to login_path
                end
            end
end
