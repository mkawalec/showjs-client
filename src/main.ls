{ShowJS} = require './ShowJS'
React    = require 'react'
{Throttled-source} = require './ThrottledSource'


window.ShowJS = (doc_id, ^^opts ? {}) ->
  addNode = ->
    # Adds a node with a given class
    wrapper = document.create-element 'div'
    wrapper.class-name = it
    document.query-selector \body .append-child wrapper
    wrapper

  mount = ->
    if not doc_id? then throw {type: 'MissingErr', msg: 'Doc id is missing'}

    opts.addr ?= 'https://showjs.io:443'
    if opts.debug is true then opts.addr = 'http://localhost:55555'

    # Init the wrapper and connection
    wrapper = add-node 'showjs-wrapper'
    socket = io opts.addr
    source = new Throttled-source socket

    React.render-component(
      ShowJS {doc_id: doc_id, socket: socket, source: source}, null
      wrapper
    )

  if document.query-selector 'body'
    mount!
  else
    window.add-event-listener 'DOMContentLoaded', mount
