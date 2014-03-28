$ = require 'jquery'
ko = require 'knockout'
page = require 'page.js'

# Facebook SDK
do (d = document, s = "script", id = "facebook-jssdk") ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  return  if d.getElementById(id)
  js = d.createElement(s)
  js.id = id
  js.src = "//connect.facebook.net/en_GB/all.js#xfbml=1&appId=623816767664793"
  fjs.parentNode.insertBefore js, fjs

# Header visibility
do ->
  $header = $('#header')
  $window = $(window)
  $cover = $('.cover')
  hidden = false
  threshold = 150

  $(window).on 'scroll', (e) ->
    distance = $cover.height() - $window.scrollTop() - $header.height()
    distance = Math.min distance, 150
    delta = distance / 150

    $header.css 'opacity', delta unless hidden

    if delta > 0 and hidden
      hidden = false
      return $header.show()

    if delta <= 0 and not hidden
      hidden = true
      $header.hide()


class ViewModel
  constructor: ->
    $window = $(window)

    @currentView = ko.observable 'main'
    @screenWidth = ko.observable $window.width()

    $window.on 'resize', =>
      @screenWidth $window.width()

    page '/', @setView 'main'
    page '/adventures', @setView 'adventures'
    page '/summer', @setView 'summer'
    page '/winter', @setView 'winter'
    page '/renting', @setView 'renting'
    page()

  setView: (name) -> =>
    @currentView name

ko.bindingHandlers.map =
  init: (el, valueAccessor) ->
    console.log 'foo'

ko.applyBindings new ViewModel

