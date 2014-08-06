class IssueshookController < ActionController::Base
    #skip_before_filter :authenticate_user

    def triggered
        issue = params["issue"]
        action = request.request_parameters['action']
        Rails.logger.info "********** the action is: #{action}**************"
        repository = params["repository"]
        if(action == "opened" || action == "closed")
        	Issue.publish_update_notice(issue, repository["owner"]["login"], repository["name"], "issues", action)
        end
        render json: "success"
    end
end
