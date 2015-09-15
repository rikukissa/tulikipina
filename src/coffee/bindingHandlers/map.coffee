L = require 'leaflet'
L.Icon.Default.imagePath = 'images/'

COORDS = [66.498150, 25.714149]

module.exports =
  init: (el, valueAccessor) ->

    process.nextTick ->
      map = new L.Map el,
        scrollWheelZoom: false

      osm = new L.TileLayer 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'

      map.setView new L.LatLng(COORDS...), 11

      L.marker(COORDS, title: 'Rovaniemi').addTo(map)

      map.addLayer osm
