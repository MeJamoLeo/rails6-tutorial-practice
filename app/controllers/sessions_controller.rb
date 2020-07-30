class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in(user) # sessionにユーザーIDを入れる
      # チェックボックスの送信結果を処理する
      if params[:session][:remember_me] == '1'
        remember(user)
      else
        forget(user)
      end
      # 同じ意味で1行にしてるやつ
      # params[:session][:remember_me] == '1' ? remember(user) : forget(user)

      redirect_to user_url(user)
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end