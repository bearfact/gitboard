gitBoard.controller("gbSprintBoardCtrl", function($scope, $routeParams, stateService, Restangular, undy, $timeout, toastHelper, issuesStatusService, milestoneHelper, $q, $modal) {
    $scope.loading = true;
    $scope.filtersopen = false;
    stateService.setCurrentSprint($routeParams.sprint_id);
    $scope.current_user = stateService.getCurrentUser();
    $scope.milestoneHelper = milestoneHelper;
    var restangular_user = null;
    $scope.query = {login: '', milestone: '', order: 'number'};
    $scope.issues = [];
    $scope.total_points = 0;
    // var dispatcher = new WebSocketRails(window.location.host+'/websocket');
    // dispatcher.on_open = function(data) {
    //   //console.log('Connection has been established: ', data);
    //   // You can trigger new server events inside this callback if you wish.
    // }


    $scope.issues_statuses = [
      {"id":5,"repository_id":2,"position":1,"name":"Backlog","label":"","created_at":"2015-08-20T02:50:36.310Z","updated_at":"2015-08-20T02:50:36.310Z","repositories_id":null},
      {"id":6,"repository_id":2,"position":2,"name":"In Progress","label":"status:in_progress","created_at":"2015-08-20T02:50:36.312Z","updated_at":"2015-08-20T02:50:36.312Z","repositories_id":null},
      {"id":7,"repository_id":2,"position":3,"name":"Ready for QA","label":"status:qa","created_at":"2015-08-20T02:50:36.314Z","updated_at":"2015-08-20T02:50:36.314Z","repositories_id":null},
      {"id":8,"repository_id":2,"position":4,"name":"Complete","label":"status:passed_qa","created_at":"2015-08-20T02:50:36.316Z","updated_at":"2015-08-20T02:50:36.316Z","repositories_id":null}
    ];

    $scope.points = [0,1,2,3]

    // var channel = dispatcher.subscribe_private(stateService.getCurrentOwner()+":"+ stateService.getCurrentRepository()+":"+"issues");
    // channel.bind('updated', function(data) {
    //   var issue = undy.findWhere($scope.issues, {id: data.id});
    //   $scope.$apply(function () {
    //         angular.extend(issue, data);
    //     });
    //     toastHelper.showSuccess("Issue "+ issue.number+" has been updated");
    // });
    //
    // channel.bind('opened', function(data) {
    //   $scope.$apply(function () {
    //         $scope.issues.push(data);
    //     });
    //   toastHelper.showSuccess("Issue #"+ data.number+" opened");
    // });
    //
    // channel.bind('closed', function(data) {
    //     var index = -1;
    //     _.each($scope.issues, function(obj, idx){
    //         if(obj.id == data.id){
    //               index = idx;
    //               return false;
    //           }
    //     });
    //     if(index > -1){
    //         $scope.$apply(function(){
    //             $scope.issues.splice(index, 1);
    //         });
    //     }
    //     toastHelper.showSuccess("Issue #"+ data.number+" closed");
    // });

    stateService.setCurrentPage("sprints");


    // $scope.$on('$destroy', function cleanup() {
    //     channel.destroy();
    //     dispatcher.disconnect();
    //     stateService.setCurrentPage("");
    // });


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
            status = issuesStatusService.getStatusByPosition(issue.new_position, $scope.issues_statuses);
            issue.status = status;
            events = Restangular.all("change_issues_status_events");
            events.post({
                issue_id: issue.id,
                status: issue.status.label,
                old_status: old_status,
                issue_number: issue.number,
                owner: issue.owner,
                repo: issue.repository
            }).then((function(data){
                angular.extend(issue, data.issue);
            }), function(){
                toastHelper.showError("Could not complete the request");
            });
        }
    });


     function load(data) {
        $scope.current_sprint = data[0]
        $scope.priorities = data[1];
        $scope.issues = data[2];
        $scope.sprints = data[3];
        $scope.column_count = $scope.issues_statuses.length;


        $scope.users = [];
        var user_names = [];
        undy.each($scope.issues, function(issue) {
            if (!undy.contains(user_names, issue.assignee.login)) {
                user_names.push(issue.assignee.login);
                $scope.users.push(issue.assignee);
            }
        });


        // if($scope.current_user.issues_board_settings){
        //     $scope.query = $scope.current_user.issues_board_settings;
        //     if(!undy.contains($scope.milestones, $scope.query.milestone)){
        //         $scope.query.milestone = "";
        //     }
        //     if(!undy.contains(user_names, $scope.query.login)){
        //         $scope.query.login = "";
        //     }
        // }

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

        calculate_total_points();

    };

    function calculate_total_points() {
      $scope.total_points = _.reduce($scope.issues, function(memo, issue){ return memo + issue.points; }, 0);
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

    $scope.change_sprint = function(issue, sprint){
        debugger;
        if(!issue.sprint || issue.sprint.id != sprint.id){
            var errorCallback, events;
            events = Restangular.all("change_issues_sprint_events");
            events.post({
                issue: {owner: issue.owner, repository: issue.repository, number: issue.number, sprint_issue_id: issue.sprint_issue_id},
                sprint_id: sprint.id
            }).then((function() {
                toastHelper.showSuccess("Sprint has been updated");
                issue.sprint = sprint;
            }), function() {
                toastHelper.showError("Could not complete the request");
            });
        }
    }

    $scope.change_points = function(issue, points){
        if(issue.points != points){
            var errorCallback, events;
            debugger;
            sprint_issue = Restangular.one("sprints", stateService.getCurrentSprint()).one("sprint_issues", issue.sprint_issue_id);
            sprint_issue.points = points;
            sprint_issue.put().then((function() {
                toastHelper.showSuccess("Points hav been updated");
                issue.points = points;
                calculate_total_points();
            }), function() {
                toastHelper.showError("Could not complete the request");
            });
        }
    }

    $scope.change_milestone = function(issue, milestone){
        if(issue.milestone.number != milestone.number){
            var errorCallback, events;
            events = Restangular.all("change_issues_milestone_events");
            events.post({
                issue_number: issue.number,
                owner: stateService.getCurrentOwner(),
                repo: stateService.getCurrentRepository(),
                milestone_number: milestone.number
            }).then((function() {
                toastHelper.showSuccess("Milestone has been updated");
                issue.milestone = milestone;
            }), function() {
                toastHelper.showError("Could not complete the request");
            });
        }
    }

    $scope.change_priority = function(issue, priority){
        var events, old_priority, priority;
        if (issue.priority !== priority.id) {
            old_priority = issue.priority
            //priority = issuesStatusService.getStatusByLabel(issue.new_status);
            priority = priority.id
            //issue.status = status;
            events = Restangular.all("change_issues_priority_events");
            events.post({
                issue_id: issue.id,
                priority: priority,
                old_priority: old_priority,
                issue_number: issue.number,
                owner: stateService.getCurrentOwner(),
                repo: stateService.getCurrentRepository()
            }).then((function(data){
                angular.extend(issue, data.issue);
                toastHelper.showSuccess("Priority has been updated");
            }), errorCallback = function(){
                toastHelper.showSuccess("Could not complete the request");
            });
        }
    }

    $scope.assign_user = function(issue, user){
        if(issue.assignee.login != user.login){
            var errorCallback, events;
            events = Restangular.all("assign_issue_events");
            return events.post({
                issue_number: issue.number,
                owner: stateService.getCurrentOwner(),
                repo: stateService.getCurrentRepository(),
                user_login: user.login
            }).then((function() {
                issue.assignee = user;
                if(user.login != 'Unassigned')
                    toastHelper.showSuccess("You have assigned the issue");
                else
                    toastHelper.showSuccess("You have unassigned the issue");
            }), function() {
                return toastHelper.showError("Could not complete the request");
            });
        }
    }


    $scope.open_comment_modal = function(issue) {
        var modal_instance;
        modal_instance = $modal.open({
            templateUrl: "/partials/gb_issue_comment_form.html",
            controller: "gbIssueCommentCtrl",
            resolve: {
                issue: function() {
                    return issue;
                },
                can_close: function() {
                    return issue.status.position == $scope.column_count;
                }
            }
        });
        modal_instance.result.then((function(res) {
            var events = Restangular.all("add_issues_comment_events");
            events.post({
                issue_id: issue.id,
                issue_number: issue.number,
                owner: stateService.getCurrentOwner(),
                repo: stateService.getCurrentRepository(),
                comment: res.comment,
                close: res.close
            }).then((function(data){
                if(res.close)
                    toastHelper.showSuccess("Issue closed with comment");
                else
                    toastHelper.showSuccess("Comment added to issue");
            }), function(){
                toastHelper.showError("Could not complete the request");
            });
        }), function() {

        });
    };

    //************************ END PUBLIC *************************************


    //************************** HELPERS ***************************
    $scope.calc_milestone_percent = function(milestone){
        return (milestone.closed_issues/(milestone.closed_issues + milestone.open_issues))*100;
    };
    //************************* END HELPERS ************************



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
