"use strict";

gitBoard.value("version", "0.1").factory("myHttpInterceptor", function($q, $location, toastHelper) {
    return {
        response: function(response) {
            var data;
            if (response.headers()["content-type"] === "application/json; charset=utf-8") {
                data = true;
                if (!data) {
                    return $q.reject(response);
                }
            }
            return response;
        },
        responseError: function(response) {
            if (response.status === 403){
                if(response.headers()['content-type'].indexOf("application/json") > -1) {
                    toastHelper.showError("Your session has expired.  Please log in again.");
                }
                else{
                    window.location = "/"
                }
            }
            return $q.reject(response);
        }
    };
}).service("issuesStatusService", function() {
    return {
        getStatusByPosition: function(position, statuses) {
            return _.findWhere(statuses, {position: position});
            /*
            switch (label) {
                case "pending":
                return {
                    label: "pending",
                    name: "Pending",
                    id: 1
                };
                case "in_progress":
                return {
                    label: "in_progress",
                    name: "In Progress",
                    id: 2
                };
                case "fixed":
                return {
                    label: "fixed",
                    name: "Fixed",
                    id: 3
                };
                case "ready_for_qa":
                return {
                    label: "ready_for_qa",
                    name: "Ready for QA",
                    id: 4
                };
                case "complete":
                return {
                    label: "complete",
                    name: "Complete",
                    id: 5
                };
                default:
                return null;
            }
            */
        },
        getStatusById: function(id) {}
    };
}).service("stateService", function() {
    var currentOwner, currentRepository, currentUser, issues_statuses, currentPage;
    currentRepository = void 0;
    currentOwner = void 0;
    currentUser = void 0;
    currentPage = void 0;
    issues_statuses = void 0;
    return {
        getCurrentRepository: function() {
            return currentRepository;
        },
        setCurrentRepository: function(id) {
            return currentRepository = id;
        },
        getCurrentOwner: function() {
            return currentOwner;
        },
        setCurrentOwner: function(id) {
            return currentOwner = id;
        },
        getCurrentUser: function() {
            return currentUser;
        },
        setCurrentUser: function(user) {
            return currentUser = user;
        },
        getIssuesStatuses: function() {
            return issues_statuses;
        },
        setIssuesStatuses: function(statuses) {
            return issues_statuses = statuses;
        },
        setActivePage: function(page){
            return currentPage = page;
        },
        setFromRoute: function(routeInfo){
            this.setCurrentRepository(routeInfo.repository_id);
            this.setCurrentOwner(routeInfo.owner_id);
        },
        repositoryUrl: function(){
            return "#/owners/"+this.getCurrentOwner()+"/repositories/"+this.getCurrentRepository();
        }
    };
});

gitBoard.factory("milestoneHelper", ["Restangular",  function(Restangular) {
    return {
        progressBarType: function(milestone){
            var a = moment(milestone.due_on);
            var b = moment(milestone.created_at);
            var c = moment();
            var totalDays = a.diff(b, 'days');
            var daysLeft = a.diff(c, 'days')
            var durationPercent = (totalDays - daysLeft)/totalDays;
            var completedPercent = milestone.closed_issues/(milestone.closed_issues+milestone.open_issues);

            if(moment().isAfter(milestone.due_on)){
                return "danger";
            }else if(durationPercent > completedPercent){
                return "warning";
            }
            return "success";
        }
    };
}]);

gitBoard.factory("toastHelper", function(toastr) {
    return {
        showSuccess: function(message, position) {
            if (position === undefined) {
                position = "toast-top-right";
            }
            return toastr.success(message, "", {
                positionClass: position
            });
        },
        showError: function(message, position) {
            if (position === undefined) {
                position = "toast-top-right";
            }
            return toastr.error(message, "", {
                positionClass: position
            });
        },
        showErrorsFromValidation: function(errors, position) {
            var arr, i, key, message;
            if (position === undefined) {
                position = "toast-top-right";
            }
            message = "";
            for (key in errors) {
                arr = errors[key];
                for (i in arr) {
                    message = message + key + " " + arr[i] + " <br />";
                }
            }
            return toastr.error(message, "", {
                extendedTimeOut: 0,
                timeOut: 0,
                positionClass: position
            });
        }
    };
});
