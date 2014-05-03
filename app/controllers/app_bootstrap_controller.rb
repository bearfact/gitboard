class AppBootstrapController < ApplicationController

    def index
        h = Hash.new
        h["current_user"] =  UserSerializer.new current_user
        #h["statuses"] = IssuesStatus::DATA
        render json: h, status: 200
    end

end
