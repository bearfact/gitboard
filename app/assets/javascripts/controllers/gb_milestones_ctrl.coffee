# gbMilestonesCtrl
ctrl = ($scope, Restangular, stateService, milestoneHelper, $routeParams, moment) ->
  'ngInject'
  stateService.setFromRoute $routeParams
  $scope.stateService = stateService
  $scope.milestoneHelper = milestoneHelper
  stateService.setCurrentPage 'milestones'

  $scope.calc_milestone_percent = (milestone) ->
    milestone.closed_issues / (milestone.closed_issues + milestone.open_issues) * 100

  $scope.github_url = ->
    'https://github.com/' + stateService.getCurrentOwner() + '/' + stateService.getCurrentRepository() + '/issues/milestones'

  $scope.milestones = Restangular.all('milestones').getList(
    repo: stateService.getCurrentRepository()
    owner: stateService.getCurrentOwner()).$object

  $scope.progress_bar_type = (milestone) ->
    a = moment(milestone.due_on)
    b = moment(milestone.created_at)
    c = moment()
    totalDays = a.diff(b, 'days')
    daysLeft = a.diff(c, 'days')
    durationPercent = (totalDays - daysLeft) / totalDays
    completedPercent = milestone.closed_issues / (milestone.closed_issues + milestone.open_issues)
    if moment().isAfter(milestone.due_on)
      return 'danger'
    else if durationPercent > completedPercent
      return 'warning'
    'success'

  return $scope

module.exports = ctrl
