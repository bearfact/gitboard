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
      si.update_attributes!(sprint_issue_params)
      res = Issue.fetch_single_issue si.owner, si.repository, si.issue_number, current_user.git_client
      updated_issue = Issue.transform(res)
      Issue.publish_update_notice(updated_issue, "issues", "updated")
      render json: updated_issue
    end

    private
    def sprint_issue_params
        params.permit(:id, :points)
    end

end
