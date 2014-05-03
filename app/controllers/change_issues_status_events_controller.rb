class ChangeIssuesStatusEventsController < ApplicationController
    def create
        cise = ChangeIssuesStatusEvent.new({
            user: current_user,
            issue_id: params[:issue_id],
            status_label: params[:status],
            old_status_label: params[:old_status],
            issue_number: params[:issue_number],
            owner: params[:owner],
            repo: params[:repo]
        })
        res = cise.save    
        render json: {issue: res}, status: 200
    end

end
