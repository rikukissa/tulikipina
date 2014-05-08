$         = require 'jquery'
_         = require 'lodash'
window.ko = ko = require 'knockout'
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

    @routes =
      '': ->
      'contacts': ->
        $.scrollTo '#contacts', 500,
          offset:
            top: -50


class SummerViewModel extends GridViewModel
  constructor: ->
    super
    @routes = ['summer', 'summer/:page']

class WinterViewModel extends GridViewModel
  constructor: ->
    super
    @routes = ['winter', 'winter/:page']

class AdventuresViewModel extends ViewModel
  constructor: ->
    super

    @routes = ['adventures', 'adventures/:page']
    @page = ko.observable 'main'

    @adventures = ko.computed =>
      data = @data()
      return [] unless data?
      _.keys data.adventures


  show: (adventure) ->
    @page adventure or 'main'

class RentingViewModel extends ViewModel
  constructor: ->
    super
    @routes = ['renting', 'renting/:page']

    @categories = ko.computed =>
      data = @data()
      return [] unless data?

      categories = []

      for id, category of data.categories
        categories.push { id, category }

      categories

  show: (products) ->
    return unless products?

    $.scrollTo '#renting-' + products, 500,
      offset:
        top: -50

class Application
  constructor: ->
    @routePrefix = '!/'

    @views = {}

    @currentView = ko.observable 'main'
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

    for name, viewModel of @views

      if _.isArray viewModel.routes
        for route in viewModel.routes
          do (name, viewModel) =>
            routes[@routePrefix + route] = =>
              @setView name
              viewModel.show.apply viewModel, arguments

      else
        for route, handler of viewModel.routes
          do (name, handler) =>
            routes[@routePrefix + route] = =>
              @setView name
              handler.apply viewModel, arguments


    routie routes

    this

app = new Application()
  .viewModel 'main',  new MainViewModel 'main'
  .viewModel 'summer', new SummerViewModel 'summer'
  .viewModel 'winter', new WinterViewModel 'winter'
  .viewModel 'adventures', new AdventuresViewModel 'adventures'
  .viewModel 'renting', new RentingViewModel 'renting'

ko.applyBindings app.init()

