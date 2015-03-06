$  = require 'jquery'
ko = require 'knockout'

module.exports =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    feed = ko.observableArray()

    $.get 'https://graph.facebook.com/tulikipina/feed',
      access_token: 'CAACEdEose0cBAHsljbWiomo1N1aMtNAquJqZA7QdKq18YnZBiYZCKbNsKZAmoBV6MTT88PwmD10L0LS8NjgcQO4t2UNO0QD0RzzZBrrZBW1A0BdUHRxv0ACbClbr6ONO4sDgSYOL6QtQ7WVJxWRX5YgpPT4hnakjCIPbWVifA5cFm9ig4AKXWz1THZBnCXo7o8DfuMZB3aD6wYq9n5DqZBlY7VZBjWt4qiLJcZD'
    .then ({data}) ->
      messages = ko.utils.arrayFilter data, (message) ->
        message.type isnt 'status' and message.message?
      .slice 0, 4

      feed messages

    innerBindingContext = bindingContext.extend
      feed: feed

    ko.applyBindingsToDescendants innerBindingContext, element

    controlsDescendantBindings: true
