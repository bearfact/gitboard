# gbIssuesBoardCtrl
ctrl = ($scope, $routeParams, stateService, Restangular, _, $timeout, ngToast, issuesStatusService, milestoneHelper, $q, $modal, token) ->
  'ngInject'
  pusher = null
  $scope.loading = true
  $scope.filtersopen = false
  stateService.setCurrentRepository $routeParams.repository_id
  stateService.setCurrentOwner $routeParams.owner_id
  stateService.setCurrentPage 'issues'
  $scope.milestoneHelper = milestoneHelper
  restangular_user = null
  $scope.query =
    login: ''
    milestone: ''
    order: 'number'
  $scope.issues = []


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
    documents_channel = pusher.subscribe("private-repo_#{stateService.getCurrentOwner()}_#{stateService.getCurrentRepository()}")
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
      status = issuesStatusService.getStatusByPosition(issue.new_position, $scope.current_repository.issues_statuses)
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

  #*************** WATCHERS **********************
  $scope.$watch 'query', ((values) ->
    if restangular_user && values
      restangular_user.issues_board_settings = values
      restangular_user.put()
    return
  ), true
  #******************* END WATCHERS *****************************

  #*********************** FETCH DATA *********************************
  fetchData = ->
    $scope.current_user = stateService.getCurrentUser()
    configureWebSocket()
    promises = []
    promises.push Restangular.all('milestones').getList(
      repo: stateService.getCurrentRepository()
      owner: stateService.getCurrentOwner())
    promises.push Restangular.all('issues_priorities').getList()
    promises.push Restangular.one('owners', stateService.getCurrentOwner()).all('users').getList()
    promises.push Restangular.one('owners', stateService.getCurrentOwner()).one('repositories', stateService.getCurrentRepository()).get()
    promises.push Restangular.one('owners', stateService.getCurrentOwner()).one('repositories', stateService.getCurrentRepository()).all('issues').getList()
    promises.push Restangular.all('sprints').getList()
    promises.push Restangular.one('users', $scope.current_user.id).get()
    $q.all(promises).then ((data) ->
      load data
      $scope.loading = false
      return
    ), (error) ->
  #****************** END FETCH DATA *****************************************

  ################# INIT PAGE ##################################
  load = (data) ->
    $scope.all_milestones = data[0]
    $scope.priorities = data[1]
    $scope.assignable_users = data[2]
    $scope.current_repository = data[3]
    $scope.issues = data[4]
    $scope.sprints = _.where(data[5], status: 'active')
    restangular_user = data[6]
    $scope.column_count = $scope.current_repository.issues_statuses.length
    $scope.milestones = _.uniq(_.pluck(_.pluck($scope.issues, 'milestone'), 'title'))
    $scope.users = []
    user_names = []
    _.each $scope.issues, (issue) ->
      if !_.contains(user_names, issue.assignee.login)
        user_names.push issue.assignee.login
        $scope.users.push issue.assignee
      return
    if $scope.current_user.issues_board_settings
      $scope.query = $scope.current_user.issues_board_settings
      if !_.contains($scope.milestones, $scope.query.milestone)
        $scope.query.milestone = ''
      if !_.contains(user_names, $scope.query.login)
        $scope.query.login = ''
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
    return
    #*******************************************************************


  fetchData()
  return $scope

module.exports = ctrl
