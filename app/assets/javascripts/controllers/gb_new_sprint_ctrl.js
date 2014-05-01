gitBoard.controller("gbNewSprintCtrl", function($scope, toastHelper, Restangular) {
    $scope.sprint = {};
    $scope.owners = Restangular.all("github_owners").getList().$object;
    $scope.submit = function(sprint) {
        var baseSprints, errorCallback, payload;
        baseSprints = Restangular.all("sprints");
        payload = {
            name: sprint.name,
            due_date: sprint.due_date,
            owner: sprint.owner
        };
        return baseSprints.post(payload).then((function(res) {
            toastHelper.showSuccess("Your sprint has been created");
            $scope.sprint = {};
            return $scope.$emit("sprintAddedEvent", null);
        }), function(err) {
            return toastHelper.showErrorsFromValidation(err.data);
        });
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
