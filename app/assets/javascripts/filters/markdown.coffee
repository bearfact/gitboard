filter = ($sce) ->
  'ngInject'
  converter = new (Showdown.converter)
  (value) ->
    html = converter.makeHtml(value or '')
    $sce.trustAsHtml html

module.exports = filter
