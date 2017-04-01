# gbEditSprintCtrl

ctrl = ($scope, $modalInstance, editable_sprint, _, Restangular, ngToast, moment) ->
  'ngInject'
  $scope.sprint = editable_sprint
  $scope.sprint.due_date = moment($scope.sprint.due_date).format("MM/DD/YYYY")
  $scope.statuses = [
    {
      id: 'active'
      name: 'ACTIVE'
    }
    {
      id: 'inactive'
      name: 'INACTIVE'
    }
    {
      id: 'complete'
      name: 'COMPLETE'
    }
  ]

  $scope.ok = ->
    if $scope.sprint.due_date
      $scope.sprint.due_date = moment($scope.sprint.due_date).endOf('day')
    $modalInstance.close $scope.sprint

  $scope.cancel = ->
    $modalInstance.dismiss 'cancel'

  $scope.add_new_column = ->
    $scope.sprint.issues_statuses.push
      name: 'A new guy'
      label: 'status:new_label'
      position: _.last($scope.sprint.issues_statuses).position + 1
    return

  $scope.remove_column = (status) ->
    status['_destroy'] = true
    if !status.id
      index = -1
      _.each $scope.sprint.issues_statuses, (obj, idx) ->
        if obj.position == status.position
          index = idx
          return false
        return
      if index > -1
        $scope.sprint.issues_statuses.splice index, 1
    return

  $scope.undo_column = (status) ->
    status['_destroy'] = false
    return

  $scope.itemMoved = (index, item) ->
    $scope.sprint.issues_statuses.splice(index, 1)
    _.each $scope.sprint.issues_statuses, (status, index) ->
      status.position = index + 1
      return
    return


  return $scope

module.exports = ctrl
