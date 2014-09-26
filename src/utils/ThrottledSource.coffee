module.exports.ThrottledSource = (socket) ->
  watchers = {}
  throttle_store = {}

  @on = (event, callback, throttle=250) ->
    # A simple event subscription 
    if not watchers[event]?
      socket.on event, _.partial(process, event, throttle)
      watchers[event] = []

    watchers[event].push callback

  @destroy = ->
    _.forEach throttle_store, (data, event) ->
      clearTimeout data.timeout
      delete throttle_store[event]

  @emit = socket.emit
    
  emit = (event, params...) ->
    # A simple emit loop
    if watchers[event]?
      _.forEach watchers[event], (watcher) ->
        watcher.apply this, params

  
  process = (event, throttle, data) ->
    if not throttle_store[event]?
      callback = _.partial(check_fulfillment, event, throttle)
      timeout = setTimeout callback, throttle
    else
      timeout = throttle_store[event].callback

    # Processes data from socketio
    throttle_store[event] =
      data: data
      fulfills: _.now() + throttle
      timeout: timeout

  check_fulfillment = (event, throttle) ->
    # If there was no new request, run the event watchers,
    # else check after the next throttle timeout
    if _.now() >= throttle_store[event].fulfills
      emit event, throttle_store[event].data
      delete throttle_store[event]
    else
      callback = _.partial(check_fulfillment, event, throttle)
      throttle_store[event].timeout = setTimeout callback, throttle

  @
