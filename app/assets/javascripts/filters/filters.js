'use strict';

gitBoard.filter('interpolate', [
'version', function(version) {
    return function(text) {
        return String(text).replace(/\%VERSION\%/mg, version);
    };
}
]);

gitBoard.filter('markdown', function ($sce) {
    var converter = new Showdown.converter();
    return function (value) {
        var html = converter.makeHtml(value || '');
        return $sce.trustAsHtml(html);
    };
});

gitBoard.filter('status', function() {
    return function( items, status) {
        var filtered = [];
        angular.forEach(items, function(item) {
            if(status == item.status.position) {
                filtered.push(item);
            }
        });
        return filtered;
    };
});

gitBoard.filter('milestone', function() {
    return function( items, milestone) {
        var filtered = [];

        if(!milestone || milestone == "")
        return items;

        angular.forEach(items, function(item) {
            if(milestone == item.milestone.title) {
                filtered.push(item);
            }
        });
        return filtered;
    };
});

gitBoard.filter('assignee', function() {
    return function( items, login) {
        var filtered = [];

        if(!login || login == "")
        return items;

        angular.forEach(items, function(item) {
            if(login == item.assignee.login) {
                filtered.push(item);
            }
        });
        return filtered;
    };
});
