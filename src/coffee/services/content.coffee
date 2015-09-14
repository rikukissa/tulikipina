$ = require 'jquery'

content = require 'content'

module.exports.get = (key) ->
  content[key]

module.exports.view = (view) ->
  content.views[view]
