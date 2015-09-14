ko = require 'knockout'

facebook = require '../services/facebook'

module.exports =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    feed = ko.observableArray()

    innerBindingContext = bindingContext.extend
      feed: feed

    ko.applyBindingsToDescendants innerBindingContext, element

    facebook.get().then (data) ->
      messages = ko.utils.arrayFilter data, (message) ->
        message.type isnt 'status' and message.message?

      feed messages

    return {controlsDescendantBindings: true}
