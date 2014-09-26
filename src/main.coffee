{SessionManager}    = require './session/SessionManager'
{Comments}          = require './comments/Comments'
{Dispatch}          = require './utils/Dispatch'
{PositionIndicator} = require './utils/PositionIndicator'
{ThrottledSource}   = require './utils/ThrottledSource'


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

    dispatch = new Dispatch()
    socket = io addr
    data_source = new ThrottledSource(socket)

    React.renderComponent(
      <SessionManager addr={addr}
                      doc_id={doc_id}
                      dispatch={dispatch}
                      # Socket is the raw SocketIO socket
                      socket={socket}
                      # Source is the Throttled source, that is the
                      # preferred thing to use in your programs
                      source={data_source}
                      />
      addNode('showjs-wrapper')
    )

    React.renderComponent(
      <PositionIndicator dispatch={dispatch}/>
      addNode('showjs-indicator')
    )

    React.renderComponent(
      <Comments source={data_source}/>
      addNode('showjs-comments')
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
