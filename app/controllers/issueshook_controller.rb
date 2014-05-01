class IssueshookController < ActionController::Base
    #skip_before_filter :authenticate_user

    def triggered
        issue = params['issue']
        repository = params['repository']
        action = request.request_parameters['action']
        if issue && repository && ["opened", "closed", "reopened"].include?(action)
          action = "updated" if ["assigned", "unassigned", "labeled", "unlabeled", "opened", "reopened"].include? action
          issue['owner'] = repository['owner']['login']
          issue['repository'] = repository['name']
          issue = Issue.transform(issue)
          Issue.publish_update_notice(issue, 'issues', action)
        end
        render json: 'success'
    end
end
