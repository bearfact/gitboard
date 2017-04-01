# gbSprintsCtrl

ctrl = ($scope, $modal, Restangular, ngToast, _, stateService, SweetAlert) ->
  'ngInject'
  stateService.setFromRoute {}
  stateService.setCurrentPage 'sprints'
  $scope.sprints = []
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
  $scope.model = status: 'active'

  $scope.delete_sprint = (sprint) ->
    SweetAlert.swal {
      title: 'Are you sure?'
      text: 'Your will not be able to recover this sprint!'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#43ac6a'
      confirmButtonText: 'Yes, delete it!'
      cancelButtonText: 'cancel'
      closeOnConfirm: false
      closeOnCancel: true
    }, (isConfirm) ->
      if isConfirm
        sprint.remove().then ->
          $scope.sprints = _.without($scope.sprints, sprint)
          SweetAlert.swal 'Deleted!', 'Your sprint has been deleted.', 'success'
          return
      return
    return

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
          ngToast.success content: 'Sprint has been updated'
          return
        return
      return
    ), ->
      return
    return

  $scope.$on 'sprintAddedEvent', (event, data) ->
    fetchSprints()
    return

  fetchSprints = ->
    Restangular.all('sprints').getList().then (res) ->
      $scope.sprints = res
      return
    return

  fetchSprints()

  return $scope

module.exports = ctrl
