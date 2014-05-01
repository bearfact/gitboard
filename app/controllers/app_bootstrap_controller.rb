class AppBootstrapController < ApplicationController

    def index
        h = Hash.new
        h["current_user"] =  UserSerializer.new current_user
        #h["statuses"] = IssuesStatus::DATA
        Rails.logger.info "my currnt user is *******************"
        Rails.logger.info current_user
        render json: h, status: 200
    end

end
