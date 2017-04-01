// 
// gitBoard.directive("appVersion", [
//     "version", function(version) {
//         return function(scope, elm, attrs) {
//             return elm.text(version);
//         };
//     }
// ]);



// gitBoard.directive("gbNoSwearing", function() {
//     return function(scope, element, attrs) {
//         var badWords, inputValue;
//         badWords = ["shit", "fuck", "cock"];
//         inputValue = "";
//         scope.$watch(attrs.ngModel, function(v) {
//             return inputValue = v;
//         });
//         return element.bind("blur", function() {
//             var found;
//             found = false;
//             _.each(badWords, function(word) {
//                 if (inputValue.indexOf(word) !== -1) {
//                     return found = true;
//                 }
//             });
//             if (found) {
//                 return element.addClass("error");
//             } else {
//                 return element.removeClass("error");
//             }
//         });
//     };
// });

// gitBoard.directive('fitToParent',['$timeout', function (timer) {
//     /* Note the injection of the $timeout service */
//     return {
//         link: function (scope, elem, attrs, ctrl) {
//             var fitToParent = function () {
//                 var p_height = elem.parent().height();
//                 elem.height(p_height);
//             }
//             timer(fitToParent, 0);
//         }
//     }
// }]);
