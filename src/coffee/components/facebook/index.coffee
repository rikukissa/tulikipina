_ = require 'lodash'
ko = require 'knockout'

{truncate} = require 'utils'
facebook = require 'services/facebook'

module.exports =
  template: require './index.jade'
  viewModel: ->
    @messages = ko.observableArray()

    facebook.get().then (data) =>

      messages = _(data)
      .filter (message) ->
        message.type isnt 'status' and message.message?
      .map (message) ->
        return message unless message.description?
        message.message = truncate message.message, 100
        message.description = truncate message.description, 200
        message
      .value()

      @messages messages

    return
