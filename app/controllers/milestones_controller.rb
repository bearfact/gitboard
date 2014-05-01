class MilestonesController < ApplicationController

    def index
        github = current_user.git_client
        milestones = github.issues.milestones.list params['owner'], params['repo']
        render json: milestones, status: 200
    end
end