$        = require 'jquery'
ko       = require 'knockout'
page     = require 'page.js'
scrollTo = require 'scrollTo'

ko.bindingHandlers.header = require './bindingHandlers/header.coffee'
ko.bindingHandlers.map    = require './bindingHandlers/map.coffee'

require './integrations.coffee'


class ViewModel
  constructor: ->
    @currentView = ko.observable 'main'

    page '/', @setView 'main'
    page '/contacts', =>
      @setView('main')()
      $.scrollTo '#contacts', 500

    page '/adventures', @setView 'adventures'
    page '/adventures/:adventure', ({params}) =>
      @setView('adventures_' + params.adventure)()

    page '/summer', @setView 'summer'
    page '/winter', @setView 'winter'
    page '/renting', @setView 'renting'
    page()


  setView: (name) -> =>
    @currentView name

ko.applyBindings new ViewModel

