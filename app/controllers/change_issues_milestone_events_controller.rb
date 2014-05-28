class ChangeIssuesMilestoneEventsController < ApiController

    def create
        cime = ChangeIssuesMilestoneEvent.new({
            user: current_user,
            issue_number: params[:issue_number],
            repo: params[:repo],
            owner: params[:owner],
            milestone_number: params[:milestone_number]
            })
        cime.save
        render json: true
    end

end
