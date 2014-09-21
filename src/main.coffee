{SessionManager} = require './SessionManager'

window.ShowJS = (doc_id, opts={}) ->
  mount = ->
    if not doc_id?
      throw {type: 'MissingErr', msg: 'Doc id is missing'}

    addr = opts.addr ? 'https://showjs.io:443'

    if opts.debug == true
      addr = 'http://localhost:55555'

    # Init the wrapper
    wrapper = document.createElement 'div'
    wrapper.className = 'showjs-wrapper'
    document.querySelector('body').appendChild wrapper

    React.renderComponent(
      <SessionManager addr={addr} doc_id={doc_id}/>
      wrapper
    )

  if document.querySelector 'body'
    mount()
  else
    window.addEventListener 'DOMContentLoaded', mount
