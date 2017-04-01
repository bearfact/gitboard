mod = [
  '$routeProvider'
  ($routeProvider) ->
    $routeProvider.when '/repositories',
      template: require '../partials/repositories.html'
      controller: 'gbRepositoriesCtrl'
    $routeProvider.when '/sprints',
      template: require '../partials/sprints.html'
      controller: 'gbSprintsCtrl'
    $routeProvider.when '/owners/:owner_id/repositories/:repository_id/issues_board',
      template: require '../partials/issues_board.html'
      controller: 'gbIssuesBoardCtrl'
    $routeProvider.when '/sprints/:sprint_id/board',
      template: require '../partials/sprint_board.html'
      controller: 'gbSprintBoardCtrl'
    $routeProvider.when '/owners/:owner_id/repositories/:repository_id/milestones',
      template: require '../partials/milestones.html'
      controller: 'gbMilestonesCtrl'
    $routeProvider.when '/profile',
      template: require '../partials/user_profile.html'
      controller: 'gbUserProfileCtrl'
    $routeProvider.when '/pagenotfound', template: require '../partials/page_not_found.html'
    $routeProvider.otherwise redirectTo: '/repositories'
]

module.exports = mod
