markdown  = require './markdown.coffee'
assignee  = require './assignee.coffee'
milestone  = require './milestone.coffee'
status  = require './status.coffee'
sprintstatus  = require './sprintstatus.coffee'



mod = angular.module('gitBoard.filters', [])
  .filter('markdown', markdown)
  .filter('assignee', assignee)
  .filter('milestone', milestone)
  .filter('status', status)
  .filter('sprintstatus', sprintstatus)
  .name;

module.exports = mod
