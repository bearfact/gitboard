class ChangeIssuesSprintEventsController < ApiController

    def create
        cise = ChangeIssuesSprintEvent.new({
            user: current_user,
            issue: params[:issue],
            sprint_id: params[:sprint_id]
            })
        cise.save
        render json: true
    end

end
