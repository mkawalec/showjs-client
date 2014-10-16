# Decorator that only continues if localStorage is available
has-store = (fn) -> -> if local-storage? then fn ...

module.exports.store-mixin =
  get-comments: has-store ->
    if local-storage.comments?
      return JSON.parse local-storage.comments
    else
      return false

  set-comments: has-store (comments) ->
    local-storage.comments = JSON.stringify comments
