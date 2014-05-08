ko = require 'knockout'

contentService = require '../services/content'

module.exports = class ViewModel
  constructor: (@name) ->
    @data = ko.observable null

    contentService.get(@name)
      .then (data) =>
        @data data
