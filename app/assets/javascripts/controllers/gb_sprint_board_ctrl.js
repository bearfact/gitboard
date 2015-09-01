gitBoard.controller("gbSprintBoardCtrl", function($scope, $routeParams, stateService, Restangular, undy, $timeout, toastHelper, issuesStatusService, milestoneHelper, $q, $modal) {
    $scope.loading = true;
    $scope.filtersopen = false;
    stateService.setCurrentSprint($routeParams.sprint_id);
    $scope.current_user = stateService.getCurrentUser();
    $scope.milestoneHelper = milestoneHelper;
    var restangular_user = null;
    $scope.query = {login: '', milestone: '', order: 'number'};
    $scope.issues = [];
    $scope.is_sprint = true;
    $scope.points = [0,1,2,3];
    $scope.total_points = 0;
    $scope.completed_points = 0;
    $scope.days_left = null;
    $scope.assignable_users = {}

    var dispatcher = new WebSocketRails(window.location.host+'/websocket');
    dispatcher.on_open = function(data) {
      console.log('Connection has been established to sprint channel: ', data);
      // You can trigger new server events inside this callback if you wish.
    }



    var channel = dispatcher.subscribe_private("sprint:"+stateService.getCurrentSprint()+":"+"issues");
    channel.bind('updated', function(data) {
      console.log('received updated from sprint channel:', data)
      var issue = undy.findWhere($scope.issues, {id: data.id});
      $scope.$apply(function () {
        if(issue) {
          angular.extend(issue, data);
        } else {
          $scope.issues.push(data)
        }
        });
        calculate_total_points();
        toastHelper.showSuccess("Issue "+ data.number+" has been updated");
    });

    channel.bind('closed', function(data) {
      console.log('received closed from sprint channel:', data)
        var index = -1;
        _.each($scope.issues, function(obj, idx){
            if(obj.id == data.id){
                  index = idx;
                  return false;
              }
        });
        if(index > -1){
            $scope.$apply(function(){
                $scope.issues.splice(index, 1);
                calculate_total_points();
            });
        }
        toastHelper.showSuccess("Issue #"+ data.number+" closed");
    });




    $scope.$on('$destroy', function cleanup() {
        channel.destroy();
        dispatcher.disconnect();
        stateService.setCurrentPage("");
    });

    stateService.setCurrentPage("sprints");

    $scope.$watch( function () { return stateService.getFilterMode(); }, function (data) {
        if(data){
            $scope.filtersopen = true;
        }else{
            $scope.filtersopen = false;
        }
    }, true);

    $scope.$on("issueDropEvent", function(event, issue) {
        var events, old_status, status;
        if (issue.new_position !== issue.status.position) {
            old_status = issue.status.label;
            status = issuesStatusService.getStatusByPosition(issue.new_position, $scope.sprint.issues_statuses);
            issue.status = status;
            events = Restangular.all("change_issues_status_events");
            events.post({
                issue: {
                  id: issue.id,
                  priority: issue.priority,
                  owner: issue.owner,
                  repository: issue.repository,
                  number: issue.number,
                  status: issue.status,
                  sprint_issue_id: issue.sprint_issue_id,
                  sprint_id: issue.sprint_id
                },
                old_status: old_status,
            }).then((function(data){
                angular.extend(issue, data.issue);
                calculate_total_points();
            }), function(){
                toastHelper.showError("Could not complete the request");
            });
        }
    });

    function get_assignable_users(){
      _.each(_.unique(_.pluck($scope.issues, "owner")), function(owner){
        Restangular.one("owners", owner).all("users").getList().then(function(users){
          $scope.assignable_users[owner] = users;
        });
      });
    }

     function load(data) {
        $scope.sprint = data[0]
        $scope.priorities = data[1];
        $scope.issues = data[2];
        $scope.sprints = data[3];
        $scope.column_count = $scope.sprint.issues_statuses.length;


        $scope.users = [];
        var user_names = [];
        undy.each($scope.issues, function(issue) {
            if (!undy.contains(user_names, issue.assignee.login)) {
                user_names.push(issue.assignee.login);
                $scope.users.push(issue.assignee);
            }
        });

        $scope.my_issues_count = undy.reduce($scope.issues, function(memo, res){
            if(res.assignee.login == $scope.current_user.login){
                return memo = memo + 1;
            }
            return memo;
        }, 0);

        $scope.unassigned_issues_count = undy.reduce($scope.issues, function(memo, res){
            if(res.assignee.login == 'Unassigned'){
                return memo = memo + 1;
            }
            return memo;
        }, 0);

        calculate_days_left();

        calculate_total_points();

        get_assignable_users();

    };

    function calculate_total_points() {
      console.log('calculating the points');
      console.log($scope.issues);
      var max_status = _.max($scope.sprint.issues_statuses, function(status){ return status.position });
      $scope.total_points = _.reduce($scope.issues, function(memo, issue){ return memo + issue.points; }, 0);
      var filtered = _.filter($scope.issues, function(issue){
        return issue.status.id == max_status.id
      });
      $scope.completed_points = _.reduce(filtered, function(memo, issue){ return memo + issue.points; }, 0);
    }

    function calculate_days_left() {
      if($scope.sprint.due_date){
        var b = moment(new Date());
        var a = moment($scope.sprint.due_date);
        $scope.days_left = a.diff(b, 'days') + 1;
      }
    }

    //**************** PUBLIC STUFF ******************
    $scope.clear_filters = function(){
        $scope.query = {login: '', milestone: '', order: 'number', searchText: ''};
    }
    $scope.close_filters = function(){
        stateService.setFilterMode(false);
    }

    $scope.toggle_filter = function(){
        stateService.setFilterMode(!stateService.getFilterMode());
    }

    $scope.set_assignee = function(login){
        $scope.query.login = login;
    }

    $scope.threat_level = function(complete, total, days) {
      if(days < 3){
        if (complete/total * 100 < 65){
          return "danger";
        }else if(complete/total * 100 < 80){
          return "warning";
        }
      }else if(days < 7){
        if (complete/total * 100 < 50){
          return "warning";
        }
      }
      return "info";
    }

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
                    calculate_days_left();
                    toastHelper.showSuccess("Sprint has been updated");
                });
            });
        }), function() {
            //toastHelper.showError("Error saving repository");
        });
    };


    //*************** WATCHERS **********************
    $scope.$watch("query", function(values){
        if(restangular_user == null){
            Restangular.one('users', $scope.current_user.id).get().then(function(user){
                restangular_user = user;
            });
        }else{
            restangular_user.issues_board_settings = values
            restangular_user.put();
        }
    }, true);

    $scope.$on("sprintPointsChangedEvent", function(event, data) {
        calculate_total_points();
    });
    //******************* END WATCHERS *****************************


    //*********************** FETCH DATA *********************************
    var promises = [];
    //promises.push(Restangular.all("milestones").getList({repo: stateService.getCurrentRepository(),owner: stateService.getCurrentOwner()}));
    promises.push(Restangular.one("sprints", stateService.getCurrentSprint()).get())
    promises.push(Restangular.all("issues_priorities").getList());
    promises.push(Restangular.one("sprints", stateService.getCurrentSprint()).all("sprint_issues").getList());
    promises.push(Restangular.all("sprints").getList());
    //promises.push(Restangular.one("owners", stateService.getCurrentOwner()).all("users").getList());
    //promises.push(Restangular.one("owners", stateService.getCurrentOwner()).one("repositories", stateService.getCurrentRepository()).get());
    //promises.push(Restangular.one("owners", stateService.getCurrentOwner()).one("repositories", stateService.getCurrentRepository()).all("issues").getList());

    $q.all(promises).then(function (data) {
        load(data);
        $scope.loading = false;
    }, function(error) {

    });
    //****************** END FETCH DATA *****************************************

});
