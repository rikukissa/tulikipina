$ = require 'jquery'
Modernizr = require 'modernizr'

module.exports =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    if not Modernizr.video or $(window).width() < 940
      $(element).parent().addClass 'no-video'
      return $(element).remove()
    element.load()
    element.play()
