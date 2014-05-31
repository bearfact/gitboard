gitBoard.controller("gbTopNavCtrl", function($scope, $location, stateService, $window) {
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
    $scope.getCurrentUser();
});
