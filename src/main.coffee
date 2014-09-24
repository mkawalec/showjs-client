{SessionManager} = require './SessionManager'
{DraggableAnchor} = require './DraggableAnchor'

window.ShowJS = (doc_id, opts={}) ->
  createWrapper = (classes) ->
    wrapper = document.createElement 'div'
    wrapper.className = classes
    document.querySelector('body').appendChild wrapper
    wrapper

  mount = ->
    if not doc_id?
      throw {type: 'MissingErr', msg: 'Doc id is missing'}

    addr = opts.addr ? 'https://showjs.io:443'

    if opts.debug == true
      addr = 'http://localhost:55555'

    # Init the wrapper
    React.initializeTouchEvents true

    React.renderComponent(
      <SessionManager addr={addr} doc_id={doc_id}/>
      createWrapper('showjs-wrapper')
    )

    React.renderComponent(
      <DraggableAnchor />
      createWrapper('showjs-anchor')
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
