module Authenticable
  extend ActiveSupport::Concern

    included do
      before_filter :authenticate_user, :except => [:authenticate_user]
      helper_method :current_user
    end

    def authenticate_user
        # respond_to do |format|
            # format.html {
                if current_user.nil?
                    redirect_to "/signin"
                elsif(current_user.status_id != 1)
                    redirect_to beta_url
                end
            # }
            # format.json {
                # if current_user.nil?
                #     render json: {error: "session_timeout"}, status: 403
                # elsif(current_user.status_id != 1)
                #     render json: {error: "terms_of_service"}, status: 403
                # end
            # }
        #end
    end

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
 end
