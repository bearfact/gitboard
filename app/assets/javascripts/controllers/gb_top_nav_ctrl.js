gitBoard.controller("gbTopNavCtrl", function($scope, $location, stateService, $window, $q, Restangular) {
    $scope.user = {
        login: ""
    };
    $scope.authcode = 200;
    $scope.titleNav = "/";
    $scope.repo_selected = false;
    $scope.repo_url = "";
    $scope.current_page = "";

    $scope.$watch( function () { return stateService.getCurrentRepository(); }, function (data) {
        if(data){
            $scope.repo_selected = true;
            $scope.repo_url = stateService.repositoryUrl();
        }else{
            $scope.repo_selected = false;
            $scope.repo_url = "";
        }
    }, true);

    $scope.$watch( function () { return stateService.getCurrentPage(); }, function (data) {
        $scope.current_page = stateService.getCurrentPage();
    }, true);

    $scope.toggle_filter = function(){
        stateService.setFilterMode(!stateService.getFilterMode());
    }

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

    function fetchData() {
      var promises = [];
      promises.push(Restangular.all("repositories").getList())
      promises.push(Restangular.all("sprints").getList())

      $q.all(promises).then(function (data) {
        $scope.repositories = data[0];
        $scope.sprints = data[1];
      }, function(error) {

      });
    }

    $scope.$on("repoAddedEvent", function(event, data) {
        fetchData();
    });

    $scope.$on("sprintAddedEvent", function(event, data) {
        fetchData();
    });

    $scope.getCurrentUser();
    fetchData();
});
