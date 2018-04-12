class ChangeWebhookEventsController < ApiController
  def create
    cwhe = ChangeWebhookEvent.new({
      user: current_user,
      owner: params[:owner],
      repo: params[:repo],
      hook_id: params[:hook_id],
    })
    res = cwhe.save
    render json: {issue: res}
  end
end
