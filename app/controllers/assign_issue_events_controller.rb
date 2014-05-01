class AssignIssueEventsController < ApplicationController

    def create
        aie = AssignIssueEvent.new({
            user: current_user,
            issue_number: params[:issue_number],
            repo: params[:repo],
            owner: params[:owner],
            user_login: params[:user_login]})
        aie.save
        render json: true, status: 200
    end

end