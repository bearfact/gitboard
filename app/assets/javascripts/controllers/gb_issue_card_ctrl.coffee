# gbIssueCardCtrl

ctrl = ($scope, Restangular, ngToast, $modal, stateService) ->
  'ngInject'
  issue_payload = (issue) ->
    {
      id: issue.id
      priority: issue.priority
      owner: issue.owner
      repository: issue.repository
      number: issue.number
      sprint_issue_id: issue.sprint_issue_id
    }

  $scope.change_sprint = (issue, sprint) ->
    original_sprint_id = sprint.id
    if !issue.sprint and sprint != 0 or issue.sprint and (issue.sprint.id != sprint.id or sprint == 0)
      errorCallback = undefined
      events = undefined
      events = Restangular.all('change_issues_sprint_events')
      events.post(
        issue:
          owner: issue.owner
          repository: issue.repository
          number: issue.number
          sprint_issue_id: issue.sprint_issue_id
        sprint_id: sprint.id or 0).then ((data) ->
        ngToast.success content: 'Sprint has been updated'
        if sprint == 0
          delete issue['sprint']
          delete issue['sprint_issue_id']
        angular.extend issue, data
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
    return

  $scope.change_points = (issue, points) ->
    if issue.points != points
      errorCallback = undefined
      events = undefined
      sprint_issue = Restangular.one('sprints', stateService.getCurrentSprint()).one('sprint_issues', issue.sprint_issue_id)
      sprint_issue.points = points
      sprint_issue.put().then (->
        issue.points = points
        $scope.$emit 'sprintPointsChangedEvent', null
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
    return

  $scope.change_milestone = (issue, milestone) ->
    if issue.milestone.number != milestone.number
      errorCallback = undefined
      events = undefined
      events = Restangular.all('change_issues_milestone_events')
      events.post(
        issue: issue_payload(issue)
        milestone_number: milestone.number).then (->
        ngToast.success content: 'Milestone has been updated'
        issue.milestone = milestone
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
    return

  $scope.change_priority = (issue, priority) ->
    `var priority`
    errorCallback = undefined
    events = undefined
    priority = undefined
    if issue.priority != priority.id
      priority = priority.id
      events = Restangular.all('change_issues_priority_events')
      events.post(
        issue: issue_payload(issue)
        priority: priority).then ((data) ->
        angular.extend issue, data.issue
        ngToast.success content: 'Priority has been updated'
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
    return

  $scope.assign_user = (issue, user) ->
    if issue.assignee.login != user.login
      errorCallback = undefined
      events = undefined
      events = Restangular.all('assign_issue_events')
      return events.post(
        issue: issue_payload(issue)
        user_login: user.login).then((->
        issue.assignee = user
        if user.login != 'Unassigned'
          ngToast.success content: 'You have assigned the issue'
        else
          ngToast.success content: 'You have unassigned the issue'
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
      )
    return

  $scope.open_comment_modal = (issue) ->
    modal_instance = undefined
    modal_instance = $modal.open(
      template: require '../../partials/gb_issue_comment_form.html'
      controller: 'gbIssueCommentCtrl'
      resolve:
        issue: ->
          issue
        can_close: ->
          issue.status.position == $scope.column_count
    )
    modal_instance.result.then ((res) ->
      events = Restangular.all('add_issues_comment_events')
      events.post(
        issue: issue_payload(issue)
        comment: res.comment
        close: res.close).then ((data) ->
        if res.close
          ngToast.success content: 'Issue closed with comment'
        else
          ngToast.success content: 'Comment added to issue'
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
      return
    ), ->
    return

  #************************ END PUBLIC *************************************
  #************************** HELPERS ***************************

  $scope.calc_milestone_percent = (milestone) ->
    milestone.closed_issues / (milestone.closed_issues + milestone.open_issues) * 100

  return $scope

module.exports = ctrl
