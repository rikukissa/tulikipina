$  = require 'jquery'
ko = require 'knockout'

module.exports =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    feed = ko.observableArray()

    $.get 'https://graph.facebook.com/tulikipina/feed',
      access_token: '623816767664793|Z0CPBw6htLxbnvVfFGZNzXMqxKI'
    .then ({data}) ->

      messages = ko.utils.arrayFilter data, (message) ->
        message.type isnt 'status' and message.message?
      .slice 0, 3

      feed messages

    innerBindingContext = bindingContext.extend
      feed: feed

    ko.applyBindingsToDescendants innerBindingContext, element

    controlsDescendantBindings: true
