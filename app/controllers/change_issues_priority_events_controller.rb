class ChangeIssuesPriorityEventsController < ApiController

    def create
        cise = ChangeIssuesPriorityEvent.new({
            user: current_user,
            issue: params[:issue],
            priority: params[:priority]
        })
        res = cise.save
        render json: {issue: res}
    end

end
