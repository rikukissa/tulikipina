content = require '../../services/content'

module.exports =
  template: require './index.jade'
  viewModel: ->
    @contacts = content.get 'contacts'

    return

