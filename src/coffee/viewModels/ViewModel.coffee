ko = require 'knockout'

contentService = require '../services/content'

module.exports = class ViewModel
  constructor: (@name) ->
    @data = ko.observable contentService.get @name

  show: ->
    document.title = "Tulikipinä - #{@data().title}"
