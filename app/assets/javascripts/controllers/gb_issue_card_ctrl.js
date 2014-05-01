gitBoard.controller("gbIssueCardCtrl", function($scope, Restangular, toastHelper, $modal, stateService) {

    var issue_payload = function(issue){''
      return {
        id: issue.id,
        priority: issue.priority,
        owner: issue.owner,
        repository: issue.repository,
        number: issue.number,
        sprint_issue_id: issue.sprint_issue_id
      }
    };

    $scope.change_sprint = function(issue, sprint){
        original_sprint_id = sprint.id
        if((!issue.sprint && sprint != 0) || (issue.sprint && (issue.sprint.id != sprint.id || sprint == 0))){
            var errorCallback, events;
            events = Restangular.all("change_issues_sprint_events");
            events.post({
                issue: {owner: issue.owner, repository: issue.repository, number: issue.number, sprint_issue_id: issue.sprint_issue_id},
                sprint_id: sprint.id || 0
            }).then((function(data) {
                toastHelper.showSuccess("Sprint has been updated");
                if(sprint == 0){
                  delete issue['sprint'];
                  delete issue['sprint_issue_id'];
                }
                angular.extend(issue, data);
            }), function() {
                toastHelper.showError("Could not complete the request");
            });
        }
    }

    $scope.change_points = function(issue, points){
      if(issue.points != points){
        var errorCallback, events;
        sprint_issue = Restangular.one("sprints", stateService.getCurrentSprint()).one("sprint_issues", issue.sprint_issue_id);
        sprint_issue.points = points;
        sprint_issue.put().then((function() {
          toastHelper.showSuccess("Points have been updated");
          issue.points = points;
          $scope.$emit("sprintPointsChangedEvent", null);
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
          issue: issue_payload(issue),
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
      var errorCallback, events, priority;
      if (issue.priority !== priority.id) {
        priority = priority.id
        events = Restangular.all("change_issues_priority_events");
        events.post({
          issue: issue_payload(issue),
          priority: priority
        }).then((function(data){
          angular.extend(issue, data.issue);
          toastHelper.showSuccess("Priority has been updated");
        }), function(){
          toastHelper.showError("Could not complete the request");
        });
      }
    }

    $scope.assign_user = function(issue, user){
      if(issue.assignee.login != user.login){
        var errorCallback, events;
        events = Restangular.all("assign_issue_events");
        return events.post({
          issue: issue_payload(issue),
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
                issue: issue_payload(issue),
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


});
