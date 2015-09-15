ko = require 'knockout'

contentService = require 'services/content'

module.exports = (name) ->
  name: name
  content: contentService.view name
  show: ->
    document.title = "Tulikipinä - #{@content.title}"
