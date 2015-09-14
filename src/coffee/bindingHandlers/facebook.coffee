_ = require 'lodash'
ko = require 'knockout'

facebook = require 'services/facebook'

truncate = (str, length) ->
  if str.length > length then str.substr(0, length) + '...' else str

module.exports =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    feed = ko.observableArray()

    innerBindingContext = bindingContext.extend
      feed: feed

    ko.applyBindingsToDescendants innerBindingContext, element

    facebook.get().then (data) ->
      messages = _(data).filter (message) ->
        message.type isnt 'status' and message.message?
      .map (message) ->
        return message unless message.description?
        message.message = truncate message.message, 100
        message.description = truncate message.description, 200
        message
      .value()

      feed messages

    return {controlsDescendantBindings: true}
