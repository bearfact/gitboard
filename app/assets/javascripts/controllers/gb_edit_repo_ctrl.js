gitBoard.controller("gbEditRepoCtrl", function($scope, $modalInstance, editable_repo, undy, Restangular, toastHelper) {
    $scope.repo = editable_repo;
    Restangular.one("github_owners", $scope.repo.owner).one("github_repositories", $scope.repo.name).all("hooks").getList().then(function(data){
        $scope.hook = undy.find(data, function(hook){ return hook.active == true && hook.name == "web" && hook.config.url == "https://gitboard.io/issueshook"});
    });

    $scope.ok = function() {
        return $modalInstance.close($scope.repo);
    };
    $scope.cancel = function() {
        return $modalInstance.dismiss("cancel");
    };

    $scope.toggle_webhook = function(){
        events = Restangular.all("change_webhook_events");
        events.post({
            owner: $scope.repo.owner,
            repo: $scope.repo.name,
            hook_id: $scope.hook ? $scope.hook.id : null
        }).then((function(data){
            if(!$scope.hook){
                $scope.hook = data;
            }else{
                $scope.hook = null;
            }
        }), function(){
            toastHelper.showError("Could not update webhook");
        });
    };

    $scope.add_new_column = function(){
        $scope.repo.issues_statuses.push({name: 'A new guy', label: 'status:new_label', position: _.last($scope.repo.issues_statuses).position+1})
    };

    $scope.remove_column = function(status){
        status["_destroy"] = true;
        if(!status.id){
            var index = -1;
            _.each($scope.repo.issues_statuses, function(obj, idx){
                if(obj.position == status.position){
                      index = idx;
                      return false;
                  }
            });
            if(index > -1){
                $scope.repo.issues_statuses.splice(index, 1);
            }
        }
    }

    $scope.undo_column = function(status){
        status["_destroy"] = false;
    }

    var tmpList = $scope.repo.issues_statuses;
    $scope.list = tmpList;

    $scope.sortableOptions = {
        stop: function(e, ui) {
            undy.each($scope.repo.issues_statuses, function(status, index){
                status.position = index+1;
            });
        }
    };

});
