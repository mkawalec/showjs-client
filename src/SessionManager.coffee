{Button}          = require './components/Button'
{Stats}           = require './Stats'
{MasterPassBox}   = require './MasterPassBox'
{helpersMixin}    = require './helpersMixin'
{passMixin}       = require './passMixin'
{ThrottledSource} = require './ThrottledSource'

module.exports.SessionManager = React.createClass
  mixins: [helpersMixin, passMixin]

  getInitialState: ->
    return {
      id: @getId()
      stats: {}
      sync_position: {}
      masterpass: @getPass()
      visibility_state: false
    }

  componentWillUnmount: ->
    if @state.stats_handle
      clearTimeout @state.stats_handle

    document.removeEventListener 'click', @toggleVisibility

  last_click: 0
  toggleVisibility: ->
    if _.now() - @last_click < 300
      @setState {visibility_state: !@state.visibility_state}
    @last_click = _.now()

  propagateSlide: (e) ->
    # Tells the other clients that they have to
    # update the current slide
    if @state.masterpass and @state.sync
      if e
        slide = {indexh: e.indexh, indexv: e.indexv}
      else
        # Figure out the coords manually
        {h, v} = Reveal.getIndices()
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
    # Set the double click handler
    document.addEventListener 'click', @toggleVisibility

    # Set the data source
    socket = io @props.addr
    source = new ThrottledSource(socket)
    @setState {socket: socket, source: source}

    socket.on 'connect', =>
      socket.emit 'join_room', {doc_id: @props.doc_id}

    socket.on 'error_msg', @notify
    Reveal.addEventListener 'slidechanged', @propagateSlide

    source.on 'sync', (data) =>
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
    # Fired when master password is set
    deferred = Q.defer()
    payload =
      pass: pass
      doc_id: @props.doc_id

    @state.socket.emit 'check_pass', payload, (data) =>
      if @state.sync
        cb = ( -> )
      else
        cb = @propagateSlide

      if data.valid == true
        @savePass pass
        @setState {masterpass: pass, sync: true}, cb
        deferred.resolve true
      else
        @notify 'Invalid password'
        deferred.reject 'Invalid password'

    return deferred.promise

  toggleSync: ->
    # The callback will be called with a new state
    if not @state.sync
      cb = @propagateSlide

      {h, v} = Reveal.getIndices()
      sync = @state.sync_position
      if not @state.masterpass and (h != sync.indexh or v != sync.indexv)
        Reveal.slide sync.indexh, sync.indexv
    else
      cb = ( -> )

    # Negate the sync state, so toggle 
    # from true to false and vice versa
    @setState {sync: not @state.sync}, cb

  releaseMaster: ->
    @clearPass()
    @setState {masterpass: undefined}

  render: ->
    classes = React.addons.classSet
      visible: @state.visibility_state
      hidden: !@state.visibility_state
      showjs: true

    (
      <div className={classes}>
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
