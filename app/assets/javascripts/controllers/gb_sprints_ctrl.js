gitBoard.controller("gbSprintsCtrl", function($scope, $modal, Restangular, toastHelper, undy, stateService, SweetAlert) {
    stateService.setFromRoute({});
    stateService.setCurrentPage('sprints');
    $scope.sprints = []
    $scope.statuses = [
      {id: "active", name: "ACTIVE"},
      {id: "inactive", name: "INACTIVE"},
      {id: "complete", name: "COMPLETE"}
    ];

    $scope.model = {
      status: "active"
    };


    $scope.delete_sprint = function(sprint){
      SweetAlert.swal({
        title: "Are you sure?",
        text: "Your will not be able to recover this sprint!",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#43ac6a",confirmButtonText: "Yes, delete it!",
        cancelButtonText: "cancel",
        closeOnConfirm: false,
        closeOnCancel: true },
        function(isConfirm){
           if (isConfirm) {
             sprint.remove().then(function(){
                 $scope.sprints = undy.without($scope.sprints, sprint);
                 SweetAlert.swal("Deleted!", "Your sprint has been deleted.", "success");
             });
           }
        });
    };

    $scope.open_edit_modal = function(sprint) {
        var editable_sprint, modal_instance;
        editable_sprint = angular.copy(sprint);
        modal_instance = $modal.open({
            templateUrl: "/partials/gb_sprint_form.html",
            controller: "gbEditSprintCtrl",
            resolve: {
                editable_sprint: function() {
                    return editable_sprint;
                }
            }
        });
        modal_instance.result.then((function(edited_sprint) {
            angular.copy(edited_sprint, sprint);
            Restangular.one("sprints", sprint.id).get({
                single: true
            }).then(function(repository) {
                sprint = Restangular.copy(sprint);
                sprint["issues_statuses_attributes"] = sprint.issues_statuses
                sprint.put().then(function(){
                    toastHelper.showSuccess("Sprint has been updated");
                });
            });
        }), function() {
            //toastHelper.showError("Error saving repository");
        });
    };


    $scope.$on("sprintAddedEvent", function(event, data) {
        fetchSprints();
    });

    var fetchSprints = function() {
        Restangular.all("sprints").getList().then(function(res){
            $scope.sprints = res;
        });
    };
    fetchSprints();
});
