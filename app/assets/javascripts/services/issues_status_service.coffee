f = (_) ->
  'ngInject'
  {
    getStatusByPosition: (position, statuses) ->
      _.findWhere statuses, position: position
  }

module.exports = f
