{SessionManager}    = require './SessionManager'
{Dispatch}          = require './Dispatch'
{PositionIndicator} = require './PositionIndicator'
{Comments}          = require './Comments'
{ThrottledSource}   = require './ThrottledSource'


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
                      socket={socket}
                      source={data_source}
                      />
      addNode('showjs-wrapper')
    )

    React.renderComponent(
      <PositionIndicator dispatch={dispatch}/>
      addNode('showjs-indicator')
    )

    React.renderComponent(
      <Comments/>
      addNode('showjs-comments')
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
