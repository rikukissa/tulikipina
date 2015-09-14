ko = require 'knockout'

ViewModel = require './ViewModel'

module.exports = class HomeViewModel extends ViewModel
  constructor: ->
    super 'home'

    @routes = [
      ''
      'contacts': ->
        $.scrollTo '#contacts', 500,
          offset:
            top: -50
    ]
