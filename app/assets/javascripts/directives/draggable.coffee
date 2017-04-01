dir = ->
  (scope, element) ->
    el = undefined
    el = element[0]
    el.draggable = true
    el.addEventListener 'dragstart', ((e) ->
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData 'Text', @id
      @classList.add 'drag'
      false
    ), false
    el.addEventListener 'dragend', ((e) ->
      @classList.remove 'drag'
      false
    ), false

module.exports = dir
