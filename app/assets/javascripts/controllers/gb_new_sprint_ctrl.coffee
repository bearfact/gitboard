# gbNewSprintCtrl
ctrl = ($scope, ngToast, Restangular, moment) ->
  'ngInject'
  $scope.sprint = {}
  $scope.owners = Restangular.all('github_owners').getList().$object

  $scope.submit = (sprint) ->
    baseSprints = undefined
    errorCallback = undefined
    payload = undefined
    baseSprints = Restangular.all('sprints')
    payload =
      name: sprint.name
      due_date: moment(sprint.due_date).format("YYYY-MM-DD")
      owner: sprint.owner
    baseSprints.post(payload).then ((res) ->
      ngToast.success content: 'Your sprint has been created'
      $scope.sprint = {}
      $scope.$emit 'sprintAddedEvent', null
    ), (err) ->
      ngToast.danger content:sFromValidation err.data


  return $scope

module.exports = ctrl
