$ = require 'jquery'

module.exports =
  init: (el, valueAccessor) ->
    hidden = false

    $el = $(el)
    height = $el.height()
    $window = $(window)

    { max, threshold } = valueAccessor()

    $(window).on 'scroll', (e) ->
      distance = max - $window.scrollTop() - height
      distance = Math.min distance, threshold
      delta = distance / threshold

      $el.css 'opacity', delta unless hidden

      if delta > 0 and hidden
        hidden = false
        return $el.show()

      if delta <= 0 and not hidden
        hidden = true
        $el.hide()
