class IssueshookController < ApplicationController
    skip_before_filter :authenticate_user

    def triggered
        issue = params["issue"]
        repository = params["repository"]
        event = issue["state"] == "open" ? "opened" : "closed"
        Issue.publish_update_notice(issue, repository["owner"]["login"], repository["name"], "issues", event)
        render json: "success", status: 200
    end
end
