gbEditRepoCtrl  = require './gb_edit_repo_ctrl.coffee'
gbEditSprintCtrl  = require './gb_edit_sprint_ctrl.coffee'
gbIssueCardCtrl  = require './gb_issue_card_ctrl.coffee'
gbIssueCommentCtrl  = require './gb_issue_comment_ctrl.coffee'
gbIssuesBoardCtrl  = require './gb_issues_board_ctrl.coffee'
gbMilestonesCtrl  = require './gb_milestones_ctrl.coffee'
gbNewRepoCtrl  = require './gb_new_repo_ctrl.coffee'
gbNewSprintCtrl  = require './gb_new_sprint_ctrl.coffee'
gbRepositoriesCtrl  = require './gb_repositories_ctrl.coffee'
gbSprintBoardCtrl  = require './gb_sprint_board_ctrl.coffee'
gbSprintsCtrl  = require './gb_sprints_ctrl.coffee'
gbTopNavCtrl  = require './gb_top_nav_ctrl.coffee'



mod = angular.module('gitBoard.controllers', [])
  .controller('gbEditRepoCtrl', gbEditRepoCtrl)
  .controller('gbEditSprintCtrl', gbEditSprintCtrl)
  .controller('gbIssueCardCtrl', gbIssueCardCtrl)
  .controller('gbIssueCommentCtrl', gbIssueCommentCtrl)
  .controller('gbIssuesBoardCtrl', gbIssuesBoardCtrl)
  .controller('gbMilestonesCtrl', gbMilestonesCtrl)
  .controller('gbNewRepoCtrl', gbNewRepoCtrl)
  .controller('gbNewSprintCtrl', gbNewSprintCtrl)
  .controller('gbRepositoriesCtrl', gbRepositoriesCtrl)
  .controller('gbSprintBoardCtrl', gbSprintBoardCtrl)
  .controller('gbSprintsCtrl', gbSprintsCtrl)
  .controller('gbTopNavCtrl', gbTopNavCtrl)
  .name;

module.exports = mod
