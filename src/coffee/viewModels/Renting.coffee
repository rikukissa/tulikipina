ko = require 'knockout'
_  = require 'lodash'

module.exports = (vm) ->
  _.extend vm,
    routes: [
      'renting'
      'renting/:page': (products) ->
        $.scrollTo '#renting-' + products, 500,
          offset:
            top: -50
    ]

    categories: _.map vm.content.categories, (category, id) ->
      { id, category }
