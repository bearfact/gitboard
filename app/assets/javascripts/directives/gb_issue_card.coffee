dir = ->
  {
    restrict: 'E'
    template: require '../../partials/templates/gb_issue_card.html'
    replace: true
    link: (scope, element, attrs) ->
      #element.addClass("panel-" + attrs.status);
      element.find('.issue-text-popover').popover()

  }

module.exports = dir
