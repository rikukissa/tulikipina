ko = require 'knockout'
_ = require 'lodash'

module.exports = (vm) ->
  subView = ko.observable 'home'

  _.extend vm,
    page: subView
    routes: [
      'adventures': ->
        subView 'home'

      'adventures/:adventure': (adventure) ->
        subView adventure
    ]

    activities: _.keys vm.content.activities
