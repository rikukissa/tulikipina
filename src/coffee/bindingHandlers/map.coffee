GMaps = require 'gmaps'

module.exports =
  init: (el, valueAccessor) ->
    process.nextTick ->
      map = new GMaps
        div: el
        lat: 66.498150
        lng: 25.714149
        zoom: 8
        scrollwheel: false
        navigationControl: false
        mapTypeControl: false
        scaleControl: false
        draggable: false

      map.addMarker
        lat: 66.498150
        lng: 25.714149
        title: 'Rovaniemi'
