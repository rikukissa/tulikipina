_  = require 'lodash'

module.exports = (vm) ->
  _.extend vm,
    routes: [
      ''
      'contacts': ->
        $.scrollTo '#contacts', 500,
          offset:
            top: -50
    ]
