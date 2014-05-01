class AddIssuesCommentEventsController < ApiController

    def create
        aice = AddIssuesCommentEvent.new({
            user: current_user,
            issue: params[:issue],
            comment: params[:comment],
            close: params[:close]
            })
        aice.save
        render json: true
    end

end
