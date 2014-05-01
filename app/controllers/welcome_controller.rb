class WelcomeController < ApplicationController
    skip_before_filter :authenticate_user, :except => [:index]

    def unauthenticated
        render 'common/signin'
    end

    def index
        render 'common/container'
    end

    def beta
      render 'common/beta'
    end

    def agree
      user = User.find(current_user.id)
      user.status_id = 1
      user.save
      redirect_to root_url
    end
end
