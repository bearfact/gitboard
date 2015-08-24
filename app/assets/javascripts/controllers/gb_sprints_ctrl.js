gitBoard.controller("gbSprintsCtrl", function($scope, $modal, Restangular, toastHelper, undy, stateService) {
    stateService.setFromRoute({});
    stateService.setCurrentPage('sprints');
    $scope.sprints = []

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
