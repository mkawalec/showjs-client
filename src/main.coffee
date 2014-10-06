{ShowJS} = require './ShowJS'
React    = require 'react'


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

    React.renderComponent(
      <ShowJS addr={addr} doc_id={doc_id} />
      wrapper
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
