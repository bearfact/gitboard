"use strict";

var gbIssuesBoardCtrl, gbMilestonesCtrl, gbNewRepoCtrl, gbRepositoriesCtrl, gbTopNavCtrl, gbUserProfileCtrl;

gitBoard.directive("appVersion", [
    "version", function(version) {
        return function(scope, elm, attrs) {
            return elm.text(version);
        };
    }
    ]);

gitBoard.controller("gbTopNavCtrl", gbTopNavCtrl = function($scope, $location, stateService, $window) {
    $scope.user = {
        login: ""
    };
    $scope.authcode = 200;
    $scope.titleNav = "/";
    $scope.repo_selected = false;
    $scope.repo_url = "";
    $scope.$watch( function () { return stateService.getCurrentRepository(); }, function (data) {
        if(data){
            $scope.repo_selected = true;
            $scope.repo_url = stateService.repositoryUrl();
        }else{
            $scope.repo_selected = false;
            $scope.repo_url = "";
        }
    }, true);

    $scope.getCurrentUser = function() {
        if (stateService.getCurrentUser()) {
            $scope.logged_in = true;
            $scope.user =stateService.getCurrentUser();
            return $scope.titleNav = "#/repositories";
        }
    };
    $scope.signout = function() {
        return $window.location.href = "/sign_out";
    };
    $scope.getCurrentUser();
});

gitBoard.controller("gbRepositoriesCtrl", gbRepositoriesCtrl = function($scope, $modal, Restangular, toastHelper, undy, stateService) {
    stateService.setFromRoute({});
    stateService.setActivePage('repos');
    $scope.delete_repo = function(repo){
        repo.remove().then(function(){
            $scope.repositories = undy.without($scope.repositories, repo);
            toastHelper.showSuccess("Repository deleted");
        });
    }
    $scope.open_edit_modal = function(repo) {
        var editable_repo, modal_instance;
        editable_repo = angular.copy(repo);
        modal_instance = $modal.open({
            templateUrl: "/partials/gb_repo_form.html",
            controller: "gbEditRepoCtrl",
            resolve: {
                editable_repo: function() {
                    return editable_repo;
                }
            }
        });
        modal_instance.result.then((function(edited_repo) {
            angular.copy(edited_repo, repo);
            Restangular.one("repositories", repo.id).get({
                single: true
            }).then(function(repository) {
                repository = Restangular.copy(repo);
                repository.put();
                toastHelper.showSuccess("Repository has been updated");
            });
        }), function() {
            //toastHelper.showError("Error saving repository");
        });
    };
    $scope.$on("repoAddedEvent", function(event, data) {
        fetchRepos();
    });
    var fetchRepos = function() {
        Restangular.all("repositories").getList().then(function(res){
            $scope.repositories = res;
        });
    };
    fetchRepos();
});

gitBoard.controller("gbEditRepoCtrl", gbNewRepoCtrl = function($scope, $modalInstance, editable_repo) {
    $scope.repo = editable_repo;
    $scope.ok = function() {
        return $modalInstance.close($scope.repo);
    };
    return $scope.cancel = function() {
        return $modalInstance.dismiss("cancel");
    };
});

gitBoard.controller("gbNewRepoCtrl", gbNewRepoCtrl = function($scope, toastHelper, Restangular) {
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
        }), errorCallback = function(err) {
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

gitBoard.controller("gbMilestonesCtrl", gbMilestonesCtrl = function($scope, Restangular, stateService, milestoneHelper, $routeParams) {
    stateService.setFromRoute($routeParams);
    $scope.stateService = stateService;
    $scope.milestoneHelper = milestoneHelper;
    $scope.calc_milestone_percent = function(milestone){
        return (milestone.closed_issues/(milestone.closed_issues + milestone.open_issues))*100;
    };

    $scope.github_url = function(){
        return "https://github.com/"+stateService.getCurrentOwner()+"/"+stateService.getCurrentRepository()+"/issues/milestones";
    }

    $scope.milestones = Restangular.all("milestones").getList({
        repo: stateService.getCurrentRepository(),
        owner: stateService.getCurrentOwner()
    }).$object;

    $scope.progress_bar_type = function(milestone){
        var a = moment(milestone.due_on);
        var b = moment(milestone.created_at);
        var c = moment();
        var totalDays = a.diff(b, 'days');
        var daysLeft = a.diff(c, 'days')
        var durationPercent = (totalDays - daysLeft)/totalDays;
        var completedPercent = milestone.closed_issues/(milestone.closed_issues+milestone.open_issues);

        if(moment().isAfter(milestone.due_on)){
            return "danger";
        }else if(durationPercent > completedPercent){
            return "warning";
        }
        return "success";

    };
});


gitBoard.controller("gbUserProfileCtrl", gbUserProfileCtrl = function($scope) {});
