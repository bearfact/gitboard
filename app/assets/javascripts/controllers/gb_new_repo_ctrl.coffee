# gbNewRepoCtrl
ctrl = ($scope, ngToast, Restangular) ->
  'ngInject'
  $scope.repo = {}
  $scope.repos = []

  $scope.submit = (repo) ->
    baseRepos = undefined
    errorCallback = undefined
    payload = undefined
    baseRepos = Restangular.all('repositories')
    payload =
      owner: repo.owner
      name: repo.name.name
      url: repo.url
      description: repo.description
    baseRepos.post(payload).then ((res) ->
      ngToast.success content: 'Your repo has been added'
      $scope.$emit 'repoAddedEvent', null
    ), (err) ->
      ngToast.danger content:sFromValidation err.data

  $scope.owners = Restangular.all('github_owners').getList().$object
  $scope.$watch 'repo.owner', (selected_owner) ->
    if selected_owner
      return $scope.repos = Restangular.one('github_owners', selected_owner).all('github_repositories').getList().$object
    return
  $scope.$watch 'repo.name', (selected_repo) ->
    if selected_repo
      $scope.repo.url = selected_repo.html_url
      return $scope.repo.description = selected_repo.description
    return

  return $scope

module.exports = ctrl
