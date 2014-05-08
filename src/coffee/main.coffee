$         = require 'jquery'
_         = require 'lodash'
window.ko = ko = require 'knockout'
routie    = require 'routie'
scrollTo  = require 'scrollTo'
Modernizr = require 'modernizr'

ko.bindingHandlers.header    = require './bindingHandlers/header.coffee'
ko.bindingHandlers.map       = require './bindingHandlers/map.coffee'
ko.bindingHandlers.video     = require './bindingHandlers/video.coffee'
ko.bindingHandlers.facebook  = require './bindingHandlers/facebook.coffee'
ko.bindingHandlers.markdown  = require './bindingHandlers/markdown.coffee'

contentService = new class ContentService
  constructor: ->
    @contentPromise = null

  get: (view) ->
    unless @contentPromise?
      @contentPromise = $.get 'content.json'

    if view
      return @contentPromise.then (data) -> data[view]

    @contentPromise

require './integrations.coffee'

class MainViewModel
  constructor: ->
    @routes = ['', 'contacts']
    @data = ko.observable null

    contentService.get('main')
      .then (data) =>
        @data data

  show: ->
    $.scrollTo '#contacts', 500,
      offset:
        top: -50

class GridViewModel
  constructor: ->
    @page = ko.observable 'main'
    @activity = ko.observable null
    @data = ko.observable null

    contentService.get(@name).then (data) =>
      @data data

    @rows = ko.computed =>
      data = @data()
      return [] unless data?

      rows = []
      currentRow = []

      for id, activity of data.activities
        if currentRow.length is 0
          rows.push currentRow

        currentRow.push
          id: id
          activity: activity

        if currentRow.length is 3
          currentRow = []

      rows

  show: (page) ->

    @page if page? then 'activity' else 'main'
    @activity page

class SummerViewModel extends GridViewModel
  constructor: ->
    @name = 'summer'
    @routes = ['summer', 'summer/:page']
    super

class WinterViewModel extends GridViewModel
  constructor: ->
    @name = 'winter'
    @routes = ['winter', 'winter/:page']
    super

class AdventuresViewModel
  constructor: ->
    @routes = ['adventures', 'adventures/:page']
    @page = ko.observable 'main'
    @data = ko.observable null
    contentService.get('adventures').then (data) =>
      @data data

    @adventures = ko.computed =>
      data = @data()
      return [] unless data?
      _.keys data.adventures


  show: (adventure) ->
    @page adventure or 'main'

class RentingViewModel
  constructor: ->
    @routes = ['renting', 'renting/:page']
    @data = ko.observable null
    contentService.get('renting').then (data) =>
      @data data

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
      for route in viewModel.routes

        routes[@routePrefix + route] = do (name, viewModel) => =>
          @setView name
          viewModel.show.apply viewModel, arguments

    routie routes

    this

app = new Application()
  .viewModel('main', new MainViewModel)
  .viewModel('summer', new SummerViewModel)
  .viewModel('winter', new WinterViewModel)
  .viewModel('adventures', new AdventuresViewModel)
  .viewModel('renting', new RentingViewModel)

ko.applyBindings app.init()

