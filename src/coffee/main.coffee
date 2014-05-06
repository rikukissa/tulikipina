$         = require 'jquery'
ko        = require 'knockout'
routie    = require 'routie'
scrollTo  = require 'scrollTo'
Modernizr = require 'modernizr'

ko.bindingHandlers.header    = require './bindingHandlers/header.coffee'
ko.bindingHandlers.map       = require './bindingHandlers/map.coffee'
ko.bindingHandlers.video     = require './bindingHandlers/video.coffee'
ko.bindingHandlers.facebook  = require './bindingHandlers/facebook.coffee'

contentService = new class ContentService
  constructor: ->
    @contentPromise = null

  get: (section, page) ->
    unless @contentPromise?
      @contentPromise = $.get 'content.json'

    @contentPromise.then (data) ->
      data[section][page]

ko.bindingHandlers.loadContent =
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    content = ko.observable null

    {section, page} = ko.unwrap valueAccessor()
    contentService.get section, page
      .then (data) ->
        content data

    innerBindingContext = bindingContext.extend
      content: content

    ko.applyBindingsToDescendants innerBindingContext, element
    controlsDescendantBindings: true

markdown = require 'markdown'

ko.bindingHandlers.markdown =
  init: (element, valueAccessor) ->
    $(element).html markdown.parse ko.unwrap valueAccessor()

require './integrations.coffee'


class ViewModel
  constructor: ->
    @currentView = ko.observable 'main'
    @dynamicPage = ko.observable null
    @navigationVisible = ko.observable false

    routie '!/',           @setView 'main'
    routie '!/summer',     @setView 'summer'
    routie '!/winter',     @setView 'winter'
    routie '!/renting',    @setView 'renting'
    routie '!/adventures', @setView 'adventures'

    routie '!/summer/:page', @setDynamic 'summer'
    routie '!/winter/:page', @setDynamic 'winter'

    routie '!/contacts', =>
      @setView('main')()

      process.nextTick ->
        $.scrollTo '#contacts', 500

    routie '!/adventures/:adventure', (adventure) =>
      @setView('adventures_' + adventure)()


  toggleNavigation: ->
    @navigationVisible not @navigationVisible()

  setDynamic: (name) -> (page) =>
    @dynamicPage
      section: name
      page: page

    @currentView 'dynamic'

  setView: (name) -> =>
    @navigationVisible false
    @currentView name

ko.applyBindings new ViewModel

