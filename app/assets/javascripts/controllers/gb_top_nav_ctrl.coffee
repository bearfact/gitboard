# gbTopNavCtrl

ctrl = ($scope, $location, stateService, $window, $q, Restangular, _) ->
  'ngInject'
  fetchData = ->
    promises = []
    promises.push Restangular.all('repositories').getList()
    promises.push Restangular.all('sprints').getList()
    $q.all(promises).then ((data) ->
      $scope.repositories = data[0]
      $scope.sprints = _.where(data[1], status: 'active')
      if stateService.getCurrentUser()
        $scope.logged_in = true
        $scope.user = stateService.getCurrentUser()
        $scope.titleNav = '/repositories'
      return
    ), (error) ->
    return

  $scope.user = login: ''
  $scope.authcode = 200
  $scope.titleNav = '/'
  $scope.repo_selected = false
  $scope.repo_url = ''
  $scope.current_page = ''
  $scope.$watch (->
    stateService.getCurrentRepository()
  ), ((data) ->
    if data
      $scope.repo_selected = true
      $scope.repo_url = stateService.repositoryUrl()
    else
      $scope.repo_selected = false
      $scope.repo_url = ''
    return
  ), true
  $scope.$watch (->
    stateService.getCurrentPage()
  ), ((data) ->
    $scope.current_page = stateService.getCurrentPage()
    return
  ), true

  $scope.toggle_filter = ->
    stateService.setFilterMode !stateService.getFilterMode()
    return

  $scope.getCurrentUser = ->
    if stateService.getCurrentUser()
      $scope.logged_in = true
      $scope.user = stateService.getCurrentUser()
      return $scope.titleNav = '/repositories'
    return

  $scope.signout = ->
    $window.location.href = '/sign_out'

  $scope.$on 'repoAddedEvent', (event, data) ->
    fetchData()
    return
  $scope.$on 'sprintAddedEvent', (event, data) ->
    fetchData()
    return
  $scope.getCurrentUser()
  fetchData()


  return $scope

module.exports = ctrl
