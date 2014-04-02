GMaps = require 'gmaps'
module.exports =
  init: (el, valueAccessor) ->
    map = new GMaps
      div: el
      lat: 66.498150
      lng: 25.714149
      zoom: 6
    map.addMarker
      lat: 66.498150
      lng: 25.714149
      title: 'Rovaniemi'
