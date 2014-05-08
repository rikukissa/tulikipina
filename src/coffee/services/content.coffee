$ = require 'jquery'

module.exports = new class ContentService
  constructor: ->
    @contentPromise = null

  get: (view) ->
    unless @contentPromise?
      @contentPromise = $.get 'content.json'

    if view
      return @contentPromise.then (data) -> data[view]

    @contentPromise
