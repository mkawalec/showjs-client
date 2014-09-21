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

  propagateSlide: (e) ->
    if @state.masterpass and @state.sync
      if e
        slide = {indexh: e.indexh, indexv: e.indexv}
      else
        {h, v} = Reveal.getIndices()
        slide = {indexh: h, indexv: v}

      payload =
        pass: @state.masterpass
        slide: slide
        setter: @state.id
        doc_id: @props.doc_id

      @state.socket.emit 'slide_change', payload

  componentWillMount: ->
    socket = io @props.addr
    @setState {socket: socket}

    socket.on 'connect', =>
      socket.emit 'join_room', {doc_id: @props.doc_id}

    socket.on 'error_msg', @notify

    Reveal.addEventListener 'slidechanged', @propagateSlide

    socket.on 'sync', (data) =>
      if @state.sync == undefined
        @setState {sync: true}

      {h, v} = Reveal.getIndices()
      if @state.sync and data.slide.setter?.id != @state.id and \
         (h != data.slide.indexh or v != data.slide.indexv)
        Reveal.slide data.slide.indexh, data.slide.indexv

    socket.on 'stats', (stats) =>
      if @state.sync == undefined
        @setState {sync: true}
      @setState {stats: stats}

  setPassword: (pass) ->
    deferred = Q.defer()
    payload =
      pass: pass
      doc_id: @props.doc_id

    @state.socket.emit 'check_pass', payload, (data) =>
      if data.valid == true
        @setState {masterpass: pass}
        deferred.resolve true
      else
        @notify 'Invalid password'
        deferred.reject 'Invalid password'

    return deferred.promise

  toggleSync: ->
    # The callback will be called with a new state
    if not @state.sync
      cb = @propagateSlide
    else
      cb = ( -> )

    @setState {sync: not @state.sync}, cb

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
