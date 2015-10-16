_ = require 'lodash'
ko = require 'knockout'

module.exports = (vm) ->
  subView = ko.observable 'home'

  activity = ko.observable null
  previousActivity = ko.observable null

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
    routes: routes
    leave: ->
      previousActivity null
