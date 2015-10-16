content = __CONTENT__

module.exports.get = (key) ->
  content[key]

module.exports.view = (view) ->
  content.views[view]
