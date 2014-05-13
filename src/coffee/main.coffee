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

contentService = require './services/content'

require './integrations'

ViewModel     = require './viewModels/ViewModel'
GridViewModel = require './viewModels/GridViewModel'

class MainViewModel extends ViewModel
  constructor: ->
    super

    @routes = [
      ''
      'contacts': ->
        $.scrollTo '#contacts', 500,
          offset:
            top: -50
    ]

class AdventuresViewModel extends ViewModel
  constructor: ->
    super
    @page = ko.observable 'main'

    @routes = [
      'adventures': ->
        @page 'main'

      'adventures/:adventure': (adventure) ->
        @page adventure
    ]

    @adventures = ko.computed =>
      data = @data()
      return [] unless data?
      _.keys data.adventures

class RentingViewModel extends ViewModel
  constructor: ->
    super

    @routes = [
      'renting'
      'renting/:page': (products) ->
        $.scrollTo '#renting-' + products, 500,
          offset:
            top: -50
    ]

    @categories = ko.computed =>
      data = @data()
      return [] unless data?

      categories = []

      for id, category of data.categories
        categories.push { id, category }

      categories

class Application
  constructor: ->
    @routePrefix = '!/'

    @views = {}

    @currentView = ko.observable 'main'
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
  .viewModel 'main',  new MainViewModel 'main'
  .viewModel 'summer', new GridViewModel 'summer'
  .viewModel 'winter', new GridViewModel 'winter'
  .viewModel 'adventures', new AdventuresViewModel 'adventures'
  .viewModel 'renting', new RentingViewModel 'renting'

ko.applyBindings app.init()

