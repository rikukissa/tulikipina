$        = require 'jquery'
ko       = require 'knockout'
page     = require 'page.js'
scrollTo = require 'scrollTo'
Modernizr = require 'modernizr'

ko.bindingHandlers.header = require './bindingHandlers/header.coffee'
ko.bindingHandlers.map    = require './bindingHandlers/map.coffee'
ko.bindingHandlers.video  = require './bindingHandlers/video.coffee'

contentService = new class ContentService
  constructor: ->
    @contentPromise = null

  get: (section, page) ->
    unless @contentPromise?
      @contentPromise = $.get('/content.json')

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

    page '/', @setView 'main'
    page '/contacts', =>
      @setView('main')()
      $.scrollTo '#contacts', 500

    page '/adventures', @setView 'adventures'
    page '/adventures/:adventure', ({params}) =>
      @setView('adventures_' + params.adventure)()

    page '/summer', @setView 'summer'
    page '/summer/:page', @setDynamic 'summer'

    page '/winter', @setView 'winter'
    page '/winter/:page', @setDynamic 'winter'

    page '/renting', @setView 'renting'
    page()

  toggleNavigation: ->
    @navigationVisible not @navigationVisible()

  setDynamic: (name) -> (ctx) =>
    @dynamicPage
      section: name
      page: ctx.params.page

    @currentView 'dynamic'

  setView: (name) -> =>
    @currentView name

ko.applyBindings new ViewModel

