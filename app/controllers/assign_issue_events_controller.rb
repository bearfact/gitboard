class AssignIssueEventsController < ApiController

    def create
        aie = AssignIssueEvent.new({
            user: current_user,
            issue: params[:issue],
            user_login: params[:user_login]})
        aie.save
        render json: true
    end

end
