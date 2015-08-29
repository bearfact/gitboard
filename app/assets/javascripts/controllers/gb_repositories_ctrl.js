gitBoard.controller("gbRepositoriesCtrl", function($scope, $modal, Restangular, toastHelper, undy, stateService, SweetAlert) {
    stateService.setFromRoute({});
    stateService.setCurrentPage('repos');
    $scope.delete_repo = function(repo){
      SweetAlert.swal({
        title: "Are you sure?",
        text: "You can always register this repository again later.",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#43ac6a",confirmButtonText: "Yes, delete it!",
        cancelButtonText: "cancel",
        closeOnConfirm: false,
        closeOnCancel: true },
        function(isConfirm){
           if (isConfirm) {
             repo.remove().then(function(){
                 $scope.repositories = undy.without($scope.repositories, repo);
                 SweetAlert.swal("Deleted!", "Your sprint has been deleted.", "success");
             });
           }
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
                repository["issues_statuses_attributes"] = repository.issues_statuses
                repository.put().then(function(){
                    toastHelper.showSuccess("Repository has been updated");
                });
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
    //fetchRepos();
});
