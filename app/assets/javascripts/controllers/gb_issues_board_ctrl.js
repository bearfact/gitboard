
gitBoard.controller("gbIssuesBoardCtrl", function($scope, $routeParams, stateService, Restangular, undy, $timeout, toastHelper, issuesStatusService, milestoneHelper, $q, $modal) {
    $scope.loading = true;
    $scope.filtersopen = false;
    stateService.setCurrentRepository($routeParams.repository_id);
    stateService.setCurrentOwner($routeParams.owner_id);
    $scope.current_user = stateService.getCurrentUser();
    $scope.milestoneHelper = milestoneHelper;
    var restangular_user = null;
    $scope.query = {login: '', milestone: '', order: 'number'};
    $scope.issues = [];
    var dispatcher = new WebSocketRails(window.location.host+'/websocket');
    dispatcher.on_open = function(data) {
      //console.log('Connection has been established: ', data);
      // You can trigger new server events inside this callback if you wish.
    }

    var channel = dispatcher.subscribe_private(stateService.getCurrentOwner()+":"+ stateService.getCurrentRepository()+":"+"issues");
    channel.bind('updated', function(data) {
      var issue = undy.findWhere($scope.issues, {id: data.id});
      $scope.$apply(function () {
        if(issue) {
          angular.extend(issue, data);
        } else {
          $scope.issues.push(data)
        }
      });
      toastHelper.showSuccess("Issue "+ data.number+" has been updated");
    });

    // channel.bind('opened', function(data) {
    //   $scope.$apply(function () {
    //         $scope.issues.push(data);
    //     });
    //   toastHelper.showSuccess("Issue #"+ data.number+" opened");
    // });

    channel.bind('closed', function(data) {
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
            });
        }
        toastHelper.showSuccess("Issue #"+ data.number+" closed");
    });




    $scope.$on('$destroy', function cleanup() {
        channel.destroy();
        dispatcher.disconnect();
        stateService.setCurrentPage("");
    });


    stateService.setCurrentPage("issues");

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
            status = issuesStatusService.getStatusByPosition(issue.new_position, $scope.current_repository.issues_statuses);
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
            }), function(){
                toastHelper.showError("Could not complete the request");
            });
        }
    });


     function load(data) {
        $scope.all_milestones = data[0];
        $scope.priorities = data[1];
        $scope.assignable_users = data[2];
        $scope.current_repository = data[3];
        $scope.issues = data[4];
        $scope.sprints = data[5];
        $scope.column_count = $scope.current_repository.issues_statuses.length;

        $scope.milestones = undy.uniq(undy.pluck(undy.pluck($scope.issues, "milestone"), "title"));

        $scope.users = [];
        var user_names = [];
        undy.each($scope.issues, function(issue) {
            if (!undy.contains(user_names, issue.assignee.login)) {
                user_names.push(issue.assignee.login);
                $scope.users.push(issue.assignee);
            }
        });


        if($scope.current_user.issues_board_settings){
            $scope.query = $scope.current_user.issues_board_settings;
            if(!undy.contains($scope.milestones, $scope.query.milestone)){
                $scope.query.milestone = "";
            }
            if(!undy.contains(user_names, $scope.query.login)){
                $scope.query.login = "";
            }
        }

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
};


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
    //******************* END WATCHERS *****************************


    //*********************** FETCH DATA *********************************
    var promises = [];
     promises.push(Restangular.all("milestones").getList({repo: stateService.getCurrentRepository(),owner: stateService.getCurrentOwner()}));
     promises.push(Restangular.all("issues_priorities").getList());
     promises.push(Restangular.one("owners", stateService.getCurrentOwner()).all("users").getList());
     promises.push(Restangular.one("owners", stateService.getCurrentOwner()).one("repositories", stateService.getCurrentRepository()).get());
     promises.push(Restangular.one("owners", stateService.getCurrentOwner()).one("repositories", stateService.getCurrentRepository()).all("issues").getList());
     promises.push(Restangular.all("sprints").getList());

    $q.all(promises).then(function (data) {
        load(data);
        $scope.loading = false;
    }, function(error) {

    });
    //****************** END FETCH DATA *****************************************

});
