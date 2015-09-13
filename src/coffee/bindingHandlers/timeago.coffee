ko      = require 'knockout'
timeago = require 'timeago'

module.exports =
  init: (element, valueAccessor) ->
    $(element).text timeago ko.unwrap valueAccessor()
