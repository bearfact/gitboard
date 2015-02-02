"use strict";

var gitBoard = angular.module("gitBoard", ["ngAnimate", "ngRoute", "restangular", "ui.bootstrap", "ui.sortable", "ngDragDrop"]);

angular.element(document).ready(function() {
		return jQuery.ajax({
				url: "/app_bootstrap",
				contentType: "application/json",
				dataType: "json",
				success: function(result) {
						//angular.bootstrap(document, ['gitBoard']);
						var ss = angular.element(document).injector().get("stateService");
						ss.setCurrentUser(result["current_user"]);
						ss.setIssuesStatuses(result["statuses"]);
				},
				async: false
		});
});


gitBoard.config([
		"$routeProvider", function($routeProvider) {
				$routeProvider.when("/", {
						templateUrl: "partials/repositories.html",
						controller: "gbRepositoriesCtrl"
				});
				$routeProvider.when("/repositories", {
						templateUrl: "partials/repositories.html",
						controller: "gbRepositoriesCtrl"
				});
				$routeProvider.when("/owners/:owner_id/repositories/:repository_id/issues_board", {
						templateUrl: "partials/issues_board.html",
						controller: "gbIssuesBoardCtrl"
				});
				$routeProvider.when("/owners/:owner_id/repositories/:repository_id/milestones", {
						templateUrl: "partials/milestones.html",
						controller: "gbMilestonesCtrl"
				});
				$routeProvider.when("/profile", {
						templateUrl: "partials/user_profile.html",
						controller: "gbUserProfileCtrl"
				});
				$routeProvider.when("/pagenotfound", {
						templateUrl: "partials/page_not_found.html"
				});
				return $routeProvider.otherwise({
						redirectTo: "/pagenotfound"
				});
		}
		]);

gitBoard.config(function($httpProvider) {
		return $httpProvider.interceptors.push("myHttpInterceptor");
});

gitBoard.config([
		"$httpProvider", function(provider) {
								provider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content");
		}
]);

gitBoard.config(function(RestangularProvider) {
		return RestangularProvider.setRequestSuffix(".json");
});

//RestangularProvider.setDefaultHeaders({'Content-Type': "application/json"});

toastr.options = {
		debug: false,
		positionClass: "toast-top-left"
};

gitBoard.value("toastr", toastr);

gitBoard.value("undy", _);
