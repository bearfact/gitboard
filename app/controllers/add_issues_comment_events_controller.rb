class AddIssuesCommentEventsController < ApiController

    def create
        Rails.logger.info params.inspect
        aice = AddIssuesCommentEvent.new({
            user: current_user,
            issue_number: params[:issue_number],
            repo: params[:repo],
            owner: params[:owner],
            comment: params[:comment],
            close: params[:close]
            })
        aice.save
        render json: true
    end

end
