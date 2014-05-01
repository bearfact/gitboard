class SessionsController < ApplicationController
    skip_before_filter :authenticate_user

    def create
        user = User.from_omniauth(env["omniauth.auth"])
        session[:user_id] = user.id
        redirect_to root_url
    end

    def destroy
        session[:user_id] = nil
        redirect_to signin_url
    end

    def show
        render json: current_user
    end
end
