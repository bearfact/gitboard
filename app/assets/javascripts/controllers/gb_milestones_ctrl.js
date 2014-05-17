gitBoard.controller("gbMilestonesCtrl", function($scope, Restangular, stateService, milestoneHelper, $routeParams) {
    stateService.setFromRoute($routeParams);
    $scope.stateService = stateService;
    $scope.milestoneHelper = milestoneHelper;
    $scope.calc_milestone_percent = function(milestone){
        return (milestone.closed_issues/(milestone.closed_issues + milestone.open_issues))*100;
    };

    $scope.github_url = function(){
        return "https://github.com/"+stateService.getCurrentOwner()+"/"+stateService.getCurrentRepository()+"/issues/milestones";
    }

    $scope.milestones = Restangular.all("milestones").getList({
        repo: stateService.getCurrentRepository(),
        owner: stateService.getCurrentOwner()
    }).$object;

    $scope.progress_bar_type = function(milestone){
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

    };
});
