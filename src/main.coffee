{ShowJS}          = require './ShowJS'
React             = require 'react'
{ThrottledSource} = require './ThrottledSource'


window.ShowJS = (doc_id, opts={}) ->
  addNode = (className) ->
    wrapper = document.createElement 'div'
    wrapper.className = className
    document.querySelector('body').appendChild wrapper
    wrapper

  mount = ->
    if not doc_id?
      throw {type: 'MissingErr', msg: 'Doc id is missing'}

    addr = opts.addr ? 'https://showjs.io:443'

    if opts.debug == true
      addr = 'http://localhost:55555'

    # Init the wrappers
    wrapper = addNode 'showjs-wrapper'
    socket = io addr
    source = new ThrottledSource(socket)

    React.renderComponent(
      <ShowJS doc_id={doc_id}
              socket={socket}
              source={source}
              />
      wrapper
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
