gitBoard.controller("gbNewRepoCtrl", function($scope, toastHelper, Restangular) {
    $scope.repo = {};
    $scope.repos = [];
    $scope.submit = function(repo) {
        var baseRepos, errorCallback, payload;
        baseRepos = Restangular.all("repositories");
        payload = {
            owner: repo.owner,
            name: repo.name.name,
            url: repo.url,
            description: repo.description
        };
        return baseRepos.post(payload).then((function(res) {
            toastHelper.showSuccess("Your repo has been added");
            return $scope.$emit("repoAddedEvent", null);
        }), function(err) {
            return toastHelper.showErrorsFromValidation(err.data);
        });
    };
    $scope.owners = Restangular.all("github_owners").getList().$object;
    $scope.$watch("repo.owner", function(selected_owner) {
        if (selected_owner) {
            return $scope.repos = Restangular.one("github_owners", selected_owner).all("github_repositories").getList().$object;
        }
    });
    return $scope.$watch("repo.name", function(selected_repo) {
        if (selected_repo) {
            $scope.repo.url = selected_repo.html_url;
            return $scope.repo.description = selected_repo.description;
        }
    });
});
