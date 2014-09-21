{Button} = require './components/Button'

module.exports.SessionManager = React.createClass
  getInitialState: ->
    return {sync: false}

  componentWillMount: ->
    socket = io @props.addr
    socket.join @props.doc_id

    socket.emit 'sync_me', {doc_id: @props.doc_id}

    socket.on 'sync', (data) ->
      console.log 'syncing', data

  render: ->
    (
      <div/>
    )
