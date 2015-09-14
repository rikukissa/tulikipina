ko = require 'knockout'

ViewModel = require './ViewModel'

module.exports = class RentingViewModel extends ViewModel
  constructor: ->
    super 'renting'

    @routes = [
      'renting'
      'renting/:page': (products) ->
        $.scrollTo '#renting-' + products, 500,
          offset:
            top: -50
    ]

    @categories = ko.computed =>
      data = @data()
      return [] unless data?

      categories = []

      for id, category of data.categories
        categories.push { id, category }

      categories
