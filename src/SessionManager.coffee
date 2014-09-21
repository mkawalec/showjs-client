{Button}       = require './components/Button'
{Stats}        = require './Stats'
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
    socket.on 'connect', =>
      socket.emit 'join_room', {doc_id: @props.doc_id}

    socket.on 'sync', (data) =>
      if @state.sync == undefined
        @setState {sync: true}

      if data.slide.setter?.id != @state.id
        Reveal.slide data.slide.indexh, data.slide.indexv

      Reveal.addEventListener 'slidechanged', (e) =>
        if @state.masterpass
          payload =
            pass: @state.masterpass
            slide: {indexh: e.indexh, indexv: e.indexv}
            setter: @state.id
            doc_id: @props.doc_id

          socket.emit 'slide_change', payload

    socket.on 'stats', (stats) =>
      if @state.sync == undefined
        @setState {sync: true}
      @setState {stats: stats}

  setPassword: ->
    pass = @refs.masterpass.getDOMNode().value
    payload =
      pass: pass
      doc_id: @props.doc_id

    socket.emit 'check_pass', payload, (data) ->
      if data.valid == true
        @setState {masterpass: pass}
      else
        @notify 'Invalid password'

  toggleSync: ->
    1

  render: ->
    (
      <div>
        <Button state={@state.sync}
                onClick={@toggleSync}
                classes='sync-btn'
                ontext='Sync on'
                offtext='Sync off'/>

        <Stats stats={@state.stats} />
      </div>
    )
