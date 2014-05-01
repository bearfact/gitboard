gitBoard.controller("gbIssueCommentCtrl", function($scope, $modalInstance, issue, can_close) {
    $scope.issue = issue;
    $scope.can_close = can_close;
    $scope.form = {
        comment: ""
    }

    $scope.ok = function() {
        return $modalInstance.close({comment: $scope.form.comment, close: false});
    };

    $scope.comment_and_close = function() {
        return $modalInstance.close({comment: $scope.form.comment, close: true});
    };

    $scope.cancel = function() {
        return $modalInstance.dismiss("cancel");
    };

});