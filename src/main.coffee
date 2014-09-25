{SessionManager}    = require './SessionManager'
{Dispatch}          = require './Dispatch'
{PositionIndicator} = require './PositionIndicator'


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
    indicator_wrapper = addNode 'showjs-indicator'

    dispatch = new Dispatch()

    React.renderComponent(
      <SessionManager addr={addr} doc_id={doc_id} dispatch={dispatch}/>
      wrapper
    )

    React.renderComponent(
      <PositionIndicator dispatch={dispatch}/>
      indicator_wrapper
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
