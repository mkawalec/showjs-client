{each, obj-to-pairs} = require 'prelude-ls'

module.exports.ThrottledSource = (socket) ->
  watchers = {}
  throttle-store = {}

  @on = (event, callback, throttle=250) ->
    # A simple event subscription
    if not watchers[event]?
      watchers[event] = []

      do
        data <-! socket.on event
        if not throttle-store[event]?
          timeout = set-timeout (!-> check-fulfillment event, throttle), throttle
        else
          timeout = throttle-store[event].timeout

        throttle-store[event] =
          data: data
          filfills: +new Date + throttle
          timeout: timeout

    watchers[event].push callback

  @destroy = ->
    throttle-store |> obj-to-pairs |> each ([event, data]) ->
      clear-timeout data.timeout
      delete throttle-store[event]

  @emit = -> socket.emit

  emit = (event, ...params) ->
    # Fire the event watchers
    watchers[event] ? [] |> each -> it.apply @, params

  check-fulfillment = (event, throttle) ->
    # If there were no new requests, run the event watchers,
    # otherwise schedule the next throttle timeout
    if +new Date >= throttle-store[event].fulfills
      emit event, throttle-store[event].data
      delete throttle-store[event]
    else
      throttle-store[event].timeout = \
        setTimeout (!-> check-fulfillment event, throttle)


  @

