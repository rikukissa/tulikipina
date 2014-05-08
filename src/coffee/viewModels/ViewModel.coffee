ko = require 'knockout'

contentService = require '../services/content'

module.exports = class ViewModel
  constructor: (@name) ->
    @data = ko.observable null

    @contentPromise = contentService.get(@name)

    @contentPromise.then (data) =>
      @data data

  show: ->
    @contentPromise.then (data) ->
      document.title = data.title
