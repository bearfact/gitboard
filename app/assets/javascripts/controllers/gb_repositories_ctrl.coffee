# gbRepositoriesCtrl
ctrl = ($scope, $modal, Restangular, ngToast, _, stateService, SweetAlert) ->
  'ngInject'
  stateService.setFromRoute {}
  stateService.setCurrentPage 'repos'

  $scope.delete_repo = (repo) ->
    SweetAlert.swal {
      title: 'Are you sure?'
      text: 'You can always register this repository again later.'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#43ac6a'
      confirmButtonText: 'Yes, delete it!'
      cancelButtonText: 'cancel'
      closeOnConfirm: false
      closeOnCancel: true
    }, (isConfirm) ->
      if isConfirm
        repo.remove().then ->
          $scope.repositories = _.without($scope.repositories, repo)
          SweetAlert.swal 'Deleted!', 'Your sprint has been deleted.', 'success'
          return
      return
    return

  $scope.open_edit_modal = (repo) ->
    editable_repo = undefined
    modal_instance = undefined
    editable_repo = angular.copy(repo)
    modal_instance = $modal.open(
      template: require '../../partials/gb_repo_form.html'
      controller: 'gbEditRepoCtrl'
      resolve: editable_repo: ->
        editable_repo
    )
    modal_instance.result.then ((edited_repo) ->
      angular.copy edited_repo, repo
      Restangular.one('repositories', repo.id).get(single: true).then (repository) ->
        repository = Restangular.copy(repo)
        repository['issues_statuses_attributes'] = repository.issues_statuses
        repository.put().then ->
          ngToast.success content: 'Repository has been updated'
          return
        return
      return
    ), ->
      return
    return

  $scope.$on 'repoAddedEvent', (event, data) ->
    fetchRepos()
    return

  fetchRepos = ->
    Restangular.all('repositories').getList().then (res) ->
      $scope.repositories = res
      return
    return

  return $scope

module.exports = ctrl
