filter = ->
  (items, milestone) ->
    filtered = []
    if !milestone or milestone == ''
      return items
    angular.forEach items, (item) ->
      if milestone == item.milestone.title
        filtered.push item
      return
    filtered

module.exports = filter
