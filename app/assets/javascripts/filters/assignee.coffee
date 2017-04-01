filter = ->
  (items, login) ->
    filtered = []
    if !login or login == ''
      return items
    angular.forEach items, (item) ->
      if login == item.assignee.login
        filtered.push item
      return
    filtered

module.exports = filter
