_ = require 'lodash'
module.exports = (vm) ->
  _.extend vm,
    rows: vm.rows.reverse()
