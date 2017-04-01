f = ->
  currentOwner = undefined
  currentRepository = undefined
  currentSprint = undefined
  currentUser = undefined
  issues_statuses = undefined
  currentPage = undefined
  filter_mode = undefined
  filter_mode = false
  currentSprint = undefined
  currentRepository = undefined
  currentOwner = undefined
  currentUser = undefined
  currentPage = undefined
  issues_statuses = undefined
  {
    getCurrentSprint: ->
      currentSprint
    setCurrentSprint: (id) ->
      currentRepository = null
      currentSprint = id
    getCurrentRepository: ->
      currentRepository
    setCurrentRepository: (id) ->
      currentRepository = id
    getCurrentOwner: ->
      currentOwner
    setCurrentOwner: (id) ->
      currentOwner = id
    getCurrentUser: ->
      currentUser || window.current_user
    setCurrentUser: (user) ->
      currentUser = user
    getIssuesStatuses: ->
      issues_statuses
    setIssuesStatuses: (statuses) ->
      issues_statuses = statuses
    getCurrentPage: ->
      currentPage
    setCurrentPage: (page) ->
      currentPage = page
    setFromRoute: (routeInfo) ->
      @setCurrentRepository routeInfo.repository_id
      @setCurrentOwner routeInfo.owner_id
      return
    repositoryUrl: ->
      '/owners/' + @getCurrentOwner() + '/repositories/' + @getCurrentRepository()
    getFilterMode: ->
      filter_mode
    setFilterMode: (val) ->
      filter_mode = val

  }

module.exports = f
