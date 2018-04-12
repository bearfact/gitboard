class ChangeIssuesStatusEventsController < ApiController
  def create
    cise = ChangeIssuesStatusEvent.new({
      user: current_user,
      issue: params[:issue],
      old_status_label: params[:old_status],
    })
    res = cise.save
    render json: {issue: res}
  end
end
