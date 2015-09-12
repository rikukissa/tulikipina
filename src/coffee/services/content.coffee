$ = require 'jquery'

content = require '../content'

module.exports.get = (view) ->
  content[view]
