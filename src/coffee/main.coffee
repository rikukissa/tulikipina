$         = require 'jquery'
_         = require 'lodash'
ko        = require 'knockout'
routie    = require 'routie'
scrollTo  = require 'scrollTo'
Modernizr = require 'modernizr'

ko.bindingHandlers.header    = require './bindingHandlers/header'
ko.bindingHandlers.map       = require './bindingHandlers/map'
ko.bindingHandlers.video     = require './bindingHandlers/video'
ko.bindingHandlers.facebook  = require './bindingHandlers/facebook'
ko.bindingHandlers.markdown  = require './bindingHandlers/markdown'
ko.bindingHandlers.timeago   = require './bindingHandlers/timeago'

ko.components.register 'tk-instagram', require './components/instagram'
ko.components.register 'tk-contacts', require './components/contacts'

require './integrations'

ViewModel     = require './viewModels/ViewModel'
Grid          = require './viewModels/Grid'
Adventures    = require './viewModels/Adventures'
Renting       = require './viewModels/Renting'
Home          = require './viewModels/Home'


class Application
  constructor: ->
    @routePrefix = '!/'

    @views = {}

    @currentView = ko.observable 'home'
    @currentViewModel = null
    @navigationVisible = ko.observable false

  toggleNavigation: ->
    @navigationVisible not @navigationVisible()

  setView: (name) ->
    @navigationVisible false
    @currentView name

  viewModel: (name, viewModel) ->
    @views[name] = viewModel

    this

  init: ->
    routes = {}

    registerRoute = (name, route, handler, vm) =>
      routes[@routePrefix + route] = =>
        if @currentViewModel? and @currentViewModel isnt vm
          @currentViewModel.leave?.apply @currentViewModel, arguments

        @currentViewModel = vm

        @setView name
        handler?.apply vm, arguments
        vm.show?.apply vm, arguments

    for name, viewModel of @views
      for route in viewModel.routes

        if typeof route is "string"
          registerRoute name, route, null, viewModel
          continue

        for path, handler of route
          registerRoute name, path, handler, viewModel

    routie routes

    this

app = new Application()
  .viewModel 'home',  Home ViewModel 'home'
  .viewModel 'summer', Grid ViewModel 'summer'
  .viewModel 'winter', Grid ViewModel 'winter'
  .viewModel 'adventures', Adventures ViewModel 'adventures'
  .viewModel 'renting', Renting ViewModel 'renting'

$ -> ko.applyBindings app.init()

