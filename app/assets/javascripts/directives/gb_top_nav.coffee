dir = ->
  return {
      restrict: "E",
      template: require "../../partials/templates/gb_top_nav.html"
      controller: "gbTopNavCtrl"
  }

module.exports = dir
