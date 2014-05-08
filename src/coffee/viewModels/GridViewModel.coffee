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

      rows = []
      currentRow = []

      for id, activity of data.activities
        if currentRow.length is 0
          rows.push currentRow

        currentRow.push
          id: id
          activity: activity

        if currentRow.length is 3
          currentRow = []

      rows


  show: (page) ->
    @page if page? then 'activity' else 'main'
    @activity page
