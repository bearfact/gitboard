class MilestonesController < ApiController
  def index
    github = current_user.git_client
    milestones = github.issues.milestones.list params["owner"], params["repo"]
    render json: milestones
  end
end
