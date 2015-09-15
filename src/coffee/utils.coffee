module.exports.truncate = (str, length) ->
  if str.length > length then str.substr(0, length) + '...' else str
