class ChangeIssuesMilestoneEventsController < ApiController
  def create
    cime = ChangeIssuesMilestoneEvent.new({
      user: current_user,
      issue: params[:issue],
      milestone_number: params[:milestone_number],
    })
    cime.save
    render json: true
  end
end
