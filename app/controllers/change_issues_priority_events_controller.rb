class ChangeIssuesPriorityEventsController < ApplicationController

    def create
        cise = ChangeIssuesPriorityEvent.new({
            user: current_user,
            issue_id: params[:issue_id],
            priority: params[:priority],
            old_priority: params[:old_priority],
            issue_number: params[:issue_number],
            owner: params[:owner],
            repo: params[:repo]
        })
        res = cise.save
        render json: {issue: res}, status: 200
    end

end