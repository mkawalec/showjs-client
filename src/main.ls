{ShowJS} = require './ShowJS'
React    = require 'react'
{ThrottledSource} = require './ThrottledSource'


window.ShowJS = (doc_id, ^^opts ? {}) ->
  addNode = ->
    # Adds a node with a given class
    wrapper = document.createElement 'div'
    wrapper.className = it
    document.querySelector \body .appendChild wrapper
    wrapper

  mount = ->
    console.log 'mount called'
    if not doc_id? then throw {type: 'MissingErr', msg: 'Doc id is missing'}

    opts.addr ?= 'https://showjs.io:443'
    if opts.debug is true then opts.addr = 'http://localhost:55555'

    # Init the wrapper and connection
    wrapper = addNode 'showjs-wrapper'
    socket = io opts.addr
    source = new ThrottledSource socket

    React.renderComponent(
      ShowJS {doc_id: doc_id, socket: socket, source: source}, null
      wrapper
    )

  if document.querySelector 'body'
    mount!
  else
    window.addEventListener 'DOMContentLoaded', mount
