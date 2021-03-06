//
// gitBoard.value("version", "0.1")).service("issuesStatusService", function() {
//     return {
//         getStatusByPosition: function(position, statuses) {
//             return _.findWhere(statuses, {position: position});
//         },
//         getStatusById: function(id) {}
//     };
// }).service("stateService", function() {
//     var currentOwner, currentRepository, currentSprint, currentUser, issues_statuses, currentPage, filter_mode;
//     filter_mode = false;
//     currentSprint = void 0;
//     currentRepository = void 0;
//     currentOwner = void 0;
//     currentUser = void 0;
//     currentPage = void 0;
//     issues_statuses = void 0;
//     return {
//         getCurrentSprint: function() {
//             return currentSprint;
//         },
//         setCurrentSprint: function(id) {
//             currentRepository = null;
//             return currentSprint = id;
//         },
//         getCurrentRepository: function() {
//             return currentRepository;
//         },
//         setCurrentRepository: function(id) {
//             return currentRepository = id;
//         },
//         getCurrentOwner: function() {
//             return currentOwner;
//         },
//         setCurrentOwner: function(id) {
//             return currentOwner = id;
//         },
//         getCurrentUser: function() {
//             return currentUser;
//         },
//         setCurrentUser: function(user) {
//             return currentUser = user;
//         },
//         getIssuesStatuses: function() {
//             return issues_statuses;
//         },
//         setIssuesStatuses: function(statuses) {
//             return issues_statuses = statuses;
//         },
//         getCurrentPage: function(){
//             return currentPage;
//         },
//         setCurrentPage: function(page){
//             return currentPage = page;
//         },
//         setFromRoute: function(routeInfo){
//             this.setCurrentRepository(routeInfo.repository_id);
//             this.setCurrentOwner(routeInfo.owner_id);
//         },
//         repositoryUrl: function(){
//             return "#/owners/"+this.getCurrentOwner()+"/repositories/"+this.getCurrentRepository();
//         },
//         getFilterMode: function() {
//             return filter_mode;
//         },
//         setFilterMode: function(val) {
//             return filter_mode = val;
//         }
//     };
// });
//
// gitBoard.factory("milestoneHelper", ["Restangular",  function(Restangular) {
//     return {
//         progressBarType: function(milestone){
//             var a = moment(milestone.due_on);
//             var b = moment(milestone.created_at);
//             var c = moment();
//             var totalDays = a.diff(b, 'days');
//             var daysLeft = a.diff(c, 'days')
//             var durationPercent = (totalDays - daysLeft)/totalDays;
//             var completedPercent = milestone.closed_issues/(milestone.closed_issues+milestone.open_issues);
//
//             if(moment().isAfter(milestone.due_on)){
//                 return "danger";
//             }else if(durationPercent > completedPercent){
//                 return "warning";
//             }
//             return "success";
//         }
//     };
// }]);
//
// gitBoard.factory("ngToast", function(toastr) {
//     return {
//         showSuccess: function(message, position) {
//             if (position === undefined) {
//                 position = "toast-top-right";
//             }
//             return toastr.success(message, "", {
//                 positionClass: position
//             });
//         },
//         showError: function(message, position) {
//             if (position === undefined) {
//                 position = "toast-top-right";
//             }
//             return toastr.error(message, "", {
//                 positionClass: position
//             });
//         },
//         showErrorsFromValidation: function(errors, position) {
//             var arr, i, key, message;
//             if (position === undefined) {
//                 position = "toast-top-right";
//             }
//             message = "";
//             for (key in errors) {
//                 arr = errors[key];
//                 for (i in arr) {
//                     message = message + key + " " + arr[i] + " <br />";
//                 }
//             }
//             return toastr.error(message, "", {
//                 extendedTimeOut: 0,
//                 timeOut: 0,
//                 positionClass: position
//             });
//         }
//     };
// });
