# gbSprintBoardCtrl
ctrl = ($scope, $routeParams, stateService, Restangular, _, $timeout, ngToast, issuesStatusService, milestoneHelper, $q, $modal, moment, token) ->
  'ngInject'
  pusher = null
  stateService.setCurrentPage 'sprints'
  stateService.setCurrentSprint $routeParams.sprint_id
  $scope.loading = true
  $scope.filtersopen = false
  $scope.current_user = stateService.getCurrentUser()
  $scope.milestoneHelper = milestoneHelper
  restangular_user = null
  $scope.query =
    login: ''
    milestone: ''
    order: 'number'
  $scope.issues = []
  $scope.is_sprint = true
  $scope.points = [
    0
    1
    2
    3
  ]
  $scope.total_points = 0
  $scope.completed_points = 0
  $scope.days_left = null
  $scope.assignable_users = {}

  get_assignable_users = ->
    _.each _.unique(_.pluck($scope.issues, 'owner')), (owner) ->
      Restangular.one('owners', owner).all('users').getList().then (users) ->
        $scope.assignable_users[owner] = users
        return
      return
    return

  configureWebSocket = ->
    pusher = new Pusher('a7b8ab23cb2cfdbd0f1e', {
      encrypted: true
      authEndpoint: "/pusher/auth"
      auth: {
        headers: {
          "X-CSRF-Token": token
        }
      }
    })
    documents_channel = pusher.subscribe("private-sprint_#{$scope.sprint.id}")
    documents_channel.bind('updated', issueUpdated)
    documents_channel.bind('opened', issueOpened)
    documents_channel.bind('closed', issueClosed)

  issueUpdated = (data) ->
    issue = _.findWhere($scope.issues, id: data.id)
    $scope.$apply ->
      if issue
        angular.extend issue, data
      else
        $scope.issues.push data
      debugger
      ngToast.success content: 'Issue ' + data.number + ' has been updated'
      return

  issueOpened = (data) ->
    $scope.$apply( () ->
      $scope.issues.push(data)
      ngToast.success content: "Issue #"+ data.number+" opened"
      return
    )


  issueClosed = (data) ->
    index = -1
    _.each $scope.issues, (obj, idx) ->
      if obj.id == data.id
        index = idx
        return false
      return
    if index > -1
      $scope.$apply ->
        $scope.issues.splice index, 1
        ngToast.success content: 'Issue #' + data.number + ' closed'
        return

  load = (data) ->
    $scope.sprint = data[0]
    $scope.priorities = data[1]
    $scope.issues = data[2]
    $scope.sprints = _.where(data[3], status: 'active')
    $scope.column_count = $scope.sprint.issues_statuses.length
    $scope.users = []
    user_names = []
    _.each $scope.issues, (issue) ->
      if !_.contains(user_names, issue.assignee.login)
        user_names.push issue.assignee.login
        $scope.users.push issue.assignee
      return
    $scope.my_issues_count = _.reduce($scope.issues, ((memo, res) ->
      if res.assignee.login == $scope.current_user.login
        return memo = memo + 1
      memo
    ), 0)
    $scope.unassigned_issues_count = _.reduce($scope.issues, ((memo, res) ->
      if res.assignee.login == 'Unassigned'
        return memo = memo + 1
      memo
    ), 0)
    calculate_days_left()
    calculate_total_points()
    get_assignable_users()
    configureWebSocket()
    return

  calculate_total_points = ->
    max_status = _.max($scope.sprint.issues_statuses, (status) ->
      status.position
    )
    $scope.total_points = _.reduce($scope.issues, ((memo, issue) ->
      memo + issue.points
    ), 0)
    filtered = _.filter($scope.issues, (issue) ->
      issue.status.id == max_status.id
    )
    $scope.completed_points = _.reduce(filtered, ((memo, issue) ->
      memo + issue.points
    ), 0)
    return

  calculate_days_left = ->
    if $scope.sprint.due_date
      b = moment(new Date)
      a = moment($scope.sprint.due_date)
      $scope.days_left = a.diff(b, 'days') + 1
    return

  $scope.$on '$destroy', ->
    if pusher
      pusher.disconnect()
    stateService.setCurrentPage ''
    return

  $scope.$watch (->
    stateService.getFilterMode()
  ), ((data) ->
    if data
      $scope.filtersopen = true
    else
      $scope.filtersopen = false
    return
  ), true


  $scope.$on 'issueDropEvent', (event, issue) ->
    events = undefined
    old_status = undefined
    status = undefined
    if issue.new_position != issue.status.position
      old_status = issue.status.label
      status = issuesStatusService.getStatusByPosition(issue.new_position, $scope.sprint.issues_statuses)
      issue.status = status
      events = Restangular.all('change_issues_status_events')
      events.post(
        issue:
          id: issue.id
          priority: issue.priority
          owner: issue.owner
          repository: issue.repository
          number: issue.number
          status: issue.status
          sprint_issue_id: issue.sprint_issue_id
          sprint_id: issue.sprint_id
        old_status: old_status).then ((data) ->
        angular.extend issue, data.issue
        calculate_total_points()
        return
      ), ->
        ngToast.danger content: 'Could not complete the request'
        return
    return
  #**************** PUBLIC STUFF ******************

  $scope.clear_filters = ->
    $scope.query =
      login: ''
      milestone: ''
      order: 'number'
      searchText: ''
    return

  $scope.close_filters = ->
    stateService.setFilterMode false
    return

  $scope.toggle_filter = ->
    stateService.setFilterMode !stateService.getFilterMode()
    return

  $scope.set_assignee = (login) ->
    $scope.query.login = login
    return

  $scope.threat_level = (complete, total, days) ->
    if days < 3
      if complete / total * 100 < 65
        return 'danger'
      else if complete / total * 100 < 80
        return 'warning'
    else if days < 7
      if complete / total * 100 < 50
        return 'warning'
    'info'

  $scope.open_edit_modal = (sprint) ->
    editable_sprint = undefined
    modal_instance = undefined
    editable_sprint = angular.copy(sprint)
    modal_instance = $modal.open(
      template: require '../../partials/gb_sprint_form.html'
      controller: 'gbEditSprintCtrl'
      resolve: editable_sprint: ->
        editable_sprint
    )
    modal_instance.result.then ((edited_sprint) ->
      angular.copy edited_sprint, sprint
      Restangular.one('sprints', sprint.id).get(single: true).then (repository) ->
        sprint = Restangular.copy(sprint)
        sprint['issues_statuses_attributes'] = sprint.issues_statuses
        sprint.put().then ->
          calculate_days_left()
          ngToast.success content: 'Sprint has been updated'
          return
        return
      return
    ), ->
      return
    return

  #*************** WATCHERS **********************
  $scope.$watch 'query', ((values) ->
    if restangular_user == null
      Restangular.one('users', $scope.current_user.id).get().then (user) ->
        restangular_user = user
        return
    else
      restangular_user.issues_board_settings = values
      restangular_user.put()
    return
  ), true


  $scope.$on 'sprintPointsChangedEvent', (event, data) ->
    calculate_total_points()
    return
  #******************* END WATCHERS *****************************


  #*********************** FETCH DATA *********************************
  promises = []
  #promises.push(Restangular.all("milestones").getList({repo: stateService.getCurrentRepository(),owner: stateService.getCurrentOwner()}));
  promises.push Restangular.one('sprints', stateService.getCurrentSprint()).get()
  promises.push Restangular.all('issues_priorities').getList()
  promises.push Restangular.one('sprints', stateService.getCurrentSprint()).all('sprint_issues').getList()
  promises.push Restangular.all('sprints').getList()
  $q.all(promises).then ((data) ->
    load data
    $scope.loading = false
    return
  ), (error) ->
    console.log error
  #****************** END FETCH DATA *****************************************

  return $scope

module.exports = ctrl
