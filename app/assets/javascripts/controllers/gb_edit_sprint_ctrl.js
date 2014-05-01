gitBoard.controller("gbEditSprintCtrl", function($scope, $modalInstance, editable_sprint, undy, Restangular, toastHelper) {
    $scope.sprint = editable_sprint;
    $scope.statuses = [
      {id: "active", name: "ACTIVE"},
      {id: "inactive", name: "INACTIVE"},
      {id: "complete", name: "COMPLETE"}
    ];

    $scope.ok = function() {
        return $modalInstance.close($scope.sprint);
    };
    $scope.cancel = function() {
        return $modalInstance.dismiss("cancel");
    };

    $scope.add_new_column = function(){
        $scope.sprint.issues_statuses.push({name: 'A new guy', label: 'status:new_label', position: _.last($scope.sprint.issues_statuses).position+1})
    };

    $scope.remove_column = function(status){
        status["_destroy"] = true;
        if(!status.id){
            var index = -1;
            _.each($scope.sprint.issues_statuses, function(obj, idx){
                if(obj.position == status.position){
                      index = idx;
                      return false;
                  }
            });
            if(index > -1){
                $scope.sprint.issues_statuses.splice(index, 1);
            }
        }
    }

    $scope.undo_column = function(status){
        status["_destroy"] = false;
    }

    var tmpList = $scope.sprint.issues_statuses;
    $scope.list = tmpList;

    $scope.sortableOptions = {
        stop: function(e, ui) {
            undy.each($scope.sprint.issues_statuses, function(status, index){
                status.position = index+1;
            });
        }
    };

    /**************** Date Picker Bullshit ***********************/
    $scope.today = function() {
      $scope.dt = new Date();
    };
    $scope.today();

    $scope.clear = function () {
      $scope.dt = null;
    };

    $scope.toggleMin = function() {
      $scope.minDate = $scope.minDate ? null : new Date();
    };
    $scope.toggleMin();

    // Disable weekend selection
    $scope.disabled = function(date, mode) {
      date2 = new Date();
      return (date.getTime() < date2.getTime());
    };

    $scope.open = function($event) {
      $scope.status.opened = true;
    };

    $scope.dateOptions = {
      formatYear: 'yy',
      startingDay: 1
    };

    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];

    $scope.status = {
      opened: false
    };

    var tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    var afterTomorrow = new Date();
    afterTomorrow.setDate(tomorrow.getDate() + 2);
    $scope.events =
      [
        {
          date: tomorrow,
          status: 'full'
        },
        {
          date: afterTomorrow,
          status: 'partially'
        }
      ];

    $scope.getDayClass = function(date, mode) {
      if (mode === 'day') {
        var dayToCheck = new Date(date).setHours(0,0,0,0);

        for (var i=0;i<$scope.events.length;i++){
          var currentDay = new Date($scope.events[i].date).setHours(0,0,0,0);

          if (dayToCheck === currentDay) {
            return $scope.events[i].status;
          }
        }
      }

      return '';
    };

});
