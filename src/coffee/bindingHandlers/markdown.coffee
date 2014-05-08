$      = require 'jquery'
marked = require 'marked'

module.exports =
  init: (element, valueAccessor) ->
    $(element).html marked ko.unwrap valueAccessor()
