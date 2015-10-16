ko = require 'knockout'
_ = require 'lodash'
content = require 'services/content'

module.exports = (vm) ->
  _.extend vm,
    routes: [
      'renting'
      'renting/:page': (products) ->
        $.scrollTo '#renting-' + products, 500,
          offset:
            top: -50
    ]

    categories: _.toArray content.get 'products'
