class SprintIssuesController < ApiController

    def index
        github = current_user.git_client
        if github
            sprint_issues = SprintIssue.fetch_for_sprint(params[:sprint_id], current_user)
            render json: sprint_issues
        else
            render json: "bad bad bad", status: 500
        end
    end

    def update
      si = SprintIssue.accessible_by_user(current_user).find(sprint_issue_params[:id])
      render json: si.update_attributes!(sprint_issue_params)
    end

    private
    def sprint_issue_params
        params.permit(:id, :points)
    end

end
