class IssuesController < ApiController
  def index
    github = current_user.git_client
    if github
      issues = Issue.fetch_by_owner_and_repo(params["owner_id"], params["repository_id"], github)
      render json: issues
    else
      render json: "bad bad bad", status: 500
    end
  end
end
