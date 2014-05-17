gitBoard.controller("gbEditRepoCtrl", function($scope, $modalInstance, editable_repo, undy) {
    $scope.repo = editable_repo;
    $scope.ok = function() {
        return $modalInstance.close($scope.repo);
    };
    $scope.cancel = function() {
        return $modalInstance.dismiss("cancel");
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
