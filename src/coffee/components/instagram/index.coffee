ko = require 'knockout'
{Instafeed} = require 'instafeed.js'

ko.bindingHandlers.instagram =
  init: (elem) ->
    id = 'insta' + Math.random()
    elem.id = id
    feed = new Instafeed
      get: 'tagged'
      tagName: 'tulikipina'
      clientId: '19ec99786b104218b8c68569bb1c3986'
      target: id
      sortBy: 'most-recent'
      limit: 12
      resolution: 'low_resolution'

    feed.run()

module.exports =
  template: """
    <div class="insta-feed" data-bind="instagram: {}">
      <a href="https://instagram.com/tulikipina" target="_blank" class="insta-feed__logo"></a>
    </div>
  """

