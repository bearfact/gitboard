gitBoard.controller("gbNewSprintCtrl", function($scope, toastHelper, Restangular) {
    $scope.sprint = {};
    $scope.owners = Restangular.all("github_owners").getList().$object;
    $scope.submit = function(sprint) {
        var baseSprints, errorCallback, payload;
        baseSprints = Restangular.all("sprints");
        payload = {
            name: sprint.name,
            due_date: sprint.due_date,
            owner: sprint.owner
        };
        return baseSprints.post(payload).then((function(res) {
            toastHelper.showSuccess("Your sprint has been created");
            $scope.sprint = {};
            return $scope.$emit("sprintAddedEvent", null);
        }), function(err) {
            return toastHelper.showErrorsFromValidation(err.data);
        });
    };

});
