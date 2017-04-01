myHttpInterceptor  = require './my_http_interceptor.coffee'
issuesStatusService  = require './issues_status_service.coffee'
stateService  = require './state_service.coffee'
milestoneHelper  = require './milestone_helper.coffee'

mod = angular.module('gitBoard.services', [])
  .factory('myHttpInterceptor', myHttpInterceptor)
  .service('issuesStatusService', issuesStatusService)
  .service('stateService', stateService)
  .factory('milestoneHelper', milestoneHelper)
  .name;

module.exports = mod
