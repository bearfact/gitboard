droppable  = require './droppable.coffee'
draggable  = require './draggable.coffee'
gbIssueCard  = require './gb_issue_card.coffee'
gbTopNav  = require './gb_top_nav.coffee'


mod = angular.module('gitBoard.directives', [])
  .directive('droppable', droppable)
  .directive('draggable', draggable)
  .directive('gbIssueCard', gbIssueCard)
  .directive('gbTopNav', gbTopNav)
  .name;

module.exports = mod
