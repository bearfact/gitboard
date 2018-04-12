class ChangeIssuesSprintEventsController < ApiController
  def create
    cise = ChangeIssuesSprintEvent.new({
      user: current_user,
      issue: params[:issue],
      sprint_id: params[:sprint_id],
    })
    updated_issue = cise.save
    render json: updated_issue
  end
end
