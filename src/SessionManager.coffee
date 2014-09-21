{Button}       = require './components/Button'
{Stats}        = require './Stats'
{MasterPassBox}= require './MasterPassBox'
{helpersMixin} = require './helpersMixin'

module.exports.SessionManager = React.createClass
  mixins: [helpersMixin]

  getInitialState: ->
    return {
      id: @getId()
      stats: {}
      sync_position: {}
    }

  componentWillUnmount: ->
    if @state.stats_handle
      clearTimeout @state.stats_handle

  propagateSlide: (e) ->
    # Fired every time the slide is changed
    if @state.masterpass and @state.sync
      if e
        slide = {indexh: e.indexh, indexv: e.indexv}
      else
        slide = {indexh: h, indexv: v}

      payload =
        pass: @state.masterpass
        slide: slide
        setter: @state.id
        doc_id: @props.doc_id

      @state.socket.emit 'slide_change', payload

    @checkSync @state.sync_position

  checkSync: (pos) ->
      {h, v} = Reveal.getIndices()

      # If we are again in sync, change the sync state to true
      if not @state.sync and pos.indexh == h and pos.indexv == v
          @setState {sync: true}
      if @state.sync and not @state.masterpass and \
          (pos.indexh != h or pos.indexv != v)
        @setState {sync: false}

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

      @setState {sync_position: data.slide}
      {h, v} = Reveal.getIndices()

      if @state.sync and data.slide.setter?.id != @state.id and \
         (h != data.slide.indexh or v != data.slide.indexv)
        Reveal.slide data.slide.indexh, data.slide.indexv

      @checkSync data.slide

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

    # Negate the sync state, so toggle 
    # from true to false and vice versa
    @setState {sync: not @state.sync}, cb

  releaseMaster: ->
    @setState {masterpass: undefined}

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
                       onMasterRelease={@releaseMaster}
                       />
      </div>
    )
