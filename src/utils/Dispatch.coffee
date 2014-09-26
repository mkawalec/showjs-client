module.exports.Dispatch = () ->
  watchers = {}

  @on = (event, callback) ->
    # A simple event subscription 
    if not watchers[event]?
      watchers[event] = []

    watchers[event].push callback

  @emit = (event, params...) ->
    # A simple emit loop
    if watchers[event]?
      _.forEach watchers[event], (watcher) ->
        watcher.apply null, params

  @
