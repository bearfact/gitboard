# gbIssueCommentCtrl
ctrl = ($scope, $modalInstance, issue, can_close) ->
  'ngInject'
  $scope.issue = issue
  $scope.can_close = can_close
  $scope.form = comment: ''

  $scope.ok = ->
    $modalInstance.close
      comment: $scope.form.comment
      close: false

  $scope.comment_and_close = ->
    $modalInstance.close
      comment: $scope.form.comment
      close: true

  $scope.cancel = ->
    $modalInstance.dismiss 'cancel'

  return $scope

module.exports = ctrl
