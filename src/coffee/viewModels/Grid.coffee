_  = require 'lodash'
ko = require 'knockout'

module.exports = (vm) ->
  subView = ko.observable 'home'

  activity = ko.observable null
  previousActivity = ko.observable null

  rows = _.chain(vm.content.activities)
    .map (activity, id) -> {id, activity}
    .groupBy (item, i) ->
      Math.floor i / 3
    .toArray()
    .value()

  routes = [
    "#{vm.name}": ->
      subView 'home'

    "#{vm.name + '/:page'}": (page) ->
      subView 'activity'
      activity page
      previousActivity page
  ]

  _.extend vm,
    page: subView
    activity: activity
    previousActivity: previousActivity
    rows: rows
    routes: routes
    leave: ->
      previousActivity null
