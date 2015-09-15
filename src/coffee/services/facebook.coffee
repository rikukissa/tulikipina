$ = require 'jquery'
ko = require 'knockout'

CACHE_INTERVAL = 1000 * 3600 * 24 # one day

module.exports.get = ->
  cache = JSON.parse window.localStorage.getItem 'facebookFeed'

  if cache and Date.now() - cache.updated < CACHE_INTERVAL
    return $.when cache.data

  $.get 'https://graph.facebook.com/tulikipina/feed',
    access_token: '623816767664793|Z0CPBw6htLxbnvVfFGZNzXMqxKI'
  .then ({data}) ->

    window.localStorage.setItem 'facebookFeed', JSON.stringify
      data: data
      updated: Date.now()

    data
