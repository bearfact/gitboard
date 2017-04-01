# gbEditRepoCtrl
ctrl = ($scope, $modalInstance, editable_repo, _, Restangular, ngToast) ->
  'ngInject'
  $scope.repo = editable_repo
  Restangular.one('github_owners', $scope.repo.owner).one('github_repositories', $scope.repo.name).all('hooks').getList().then (data) ->
    $scope.hook = _.find(data, (hook) ->
      hook.active == true and hook.name == 'web' and hook.config.url == 'https://gitboard.io/issueshook'
    )
    return

  $scope.ok = ->
    $modalInstance.close $scope.repo

  $scope.cancel = ->
    $modalInstance.dismiss 'cancel'

  $scope.toggle_webhook = ->
    events = Restangular.all('change_webhook_events')
    events.post(
      owner: $scope.repo.owner
      repo: $scope.repo.name
      hook_id: if $scope.hook then $scope.hook.id else null).then ((data) ->
      if !$scope.hook
        $scope.hook = data
      else
        $scope.hook = null
      return
    ), ->
      ngToast.danger content: 'Could not update webhook'
      return
    return

  $scope.add_new_column = ->
    $scope.repo.issues_statuses.push
      name: 'A new guy'
      label: 'status:new_label'
      position: _.last($scope.repo.issues_statuses).position + 1
    return

  $scope.remove_column = (status) ->
    status['_destroy'] = true
    if !status.id
      index = -1
      _.each $scope.repo.issues_statuses, (obj, idx) ->
        if obj.position == status.position
          index = idx
          return false
        return
      if index > -1
        $scope.repo.issues_statuses.splice index, 1
    return

  $scope.undo_column = (status) ->
    status['_destroy'] = false
    return

  $scope.itemMoved = (index, item) ->
    $scope.repo.issues_statuses.splice(index, 1)
    _.each $scope.repo.issues_statuses, (status, index) ->
      status.position = index + 1
      return
    return

  return $scope

module.exports = ctrl
