filter = ->
  (items, status) ->
    filtered = []
    angular.forEach items, (item) ->
      if status == item.status.position
        filtered.push item
      return
    filtered

module.exports = filter
