_  = require 'lodash'
ko = require 'knockout'

ViewModel = require './ViewModel'

module.exports = class GridViewModel extends ViewModel
  constructor: ->
    super
    @page = ko.observable 'main'
    @activity = ko.observable null

    @rows = ko.computed =>
      data = @data()
      return [] unless data?

      _.chain(data.activities).map (activity, id) ->
        { id, activity }
      .groupBy (item, i) ->
        Math.floor i / 3
      .toArray().value()
