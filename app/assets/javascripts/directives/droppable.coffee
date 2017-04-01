dir = ->
  {
    scope: drop: '&drop'
    link: (scope, element) ->
      el = undefined
      el = element[0]
      el.addEventListener 'dragover', ((e) ->
        e.dataTransfer.dropEffect = 'move'
        if e.preventDefault
          e.preventDefault()
        @classList.add 'over'
        false
      ), false
      el.addEventListener 'dragenter', ((e) ->
        @classList.add 'over'
        false
      ), false
      el.addEventListener 'dragleave', ((e) ->
        @classList.remove 'over'
        false
      ), false
      el.addEventListener 'drop', ((e) ->
        data = undefined
        item = undefined
        if e.preventDefault
          e.preventDefault()
        if e.stopPropagation
          e.stopPropagation()
        @classList.remove 'over'
        item = document.getElementById(e.dataTransfer.getData('Text'))
        data = $(item).data().$scope.issue
        data['new_position'] = scope.drop()
        scope.$emit 'issueDropEvent', data
        false
      ), false

  }

module.exports = dir
