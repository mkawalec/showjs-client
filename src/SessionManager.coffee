{Button}       = require './components/Button'
{Stats}        = require './Stats'
{MasterPassBox}= require './MasterPassBox'
{helpersMixin} = require './helpersMixin'

module.exports.SessionManager = React.createClass
  mixins: [helpersMixin]

  getInitialState: ->
    return {
      id: @get_id()
      stats: {}
    }

  componentWillUnmount: ->
    if @state.stats_handle
      clearTimeout @state.stats_handle

  componentWillMount: ->
    socket = io @props.addr
    @setState {socket: socket}

    socket.on 'connect', =>
      socket.emit 'join_room', {doc_id: @props.doc_id}

    socket.on 'error_msg', (err) ->
      console?.error err

    Reveal.addEventListener 'slidechanged', (e) =>
      if @state.masterpass
        payload =
          pass: @state.masterpass
          slide: {indexh: e.indexh, indexv: e.indexv}
          setter: @state.id
          doc_id: @props.doc_id

        socket.emit 'slide_change', payload

    socket.on 'sync', (data) =>
      if @state.sync == undefined
        @setState {sync: true}

      if @state.sync != false and data.slide.setter?.id != @state.id
        Reveal.slide data.slide.indexh, data.slide.indexv

    socket.on 'stats', (stats) =>
      if @state.sync == undefined
        @setState {sync: true}
      console.log 'stats', stats
      @setState {stats: stats}

  setPassword: (pass) ->
    deferred = Q.defer()
    payload =
      pass: pass
      doc_id: @props.doc_id

    @state.socket.emit 'check_pass', payload, (data) =>
      console.log data
      if data.valid == true
        @setState {masterpass: pass}
        deferred.resolve true
      else
        @notify 'Invalid password'
        deferred.reject 'Invalid password'

    return deferred.promise

  toggleSync: ->
    1

  render: ->
    (
      <div>
        <Button state={@state.sync}
                onClick={@toggleSync}
                classes='sync-btn'
                ontext='Sync on'
                offtext='Sync off'
                />

        <Stats stats={@state.stats} />

        <MasterPassBox pass={@state.masterpass}
                       onPassSet={@setPassword}
                       />
      </div>
    )
