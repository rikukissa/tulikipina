ko = require 'knockout'
_  = require 'lodash'

ViewModel = require './ViewModel'

module.exports = class AdventuresViewModel extends ViewModel
  constructor: ->
    super 'adventures'

    @page = ko.observable 'home'

    @routes = [
      'adventures': ->
        @page 'home'

      'adventures/:adventure': (adventure) ->
        @page adventure
    ]

    @adventures = ko.computed =>
      data = @data()
      return [] unless data?
      _.keys data.adventures
