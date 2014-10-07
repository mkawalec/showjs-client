{Button}            = require '../components/Button'
{Stats}             = require './Stats'
{MasterPassBox}     = require './MasterPassBox'
{helpersMixin}      = require './helpersMixin'
{passMixin}         = require './passMixin'

React  = require 'react'
addons = require 'react-addons'


module.exports.SessionManager = React.createClass
  mixins: [helpersMixin, passMixin]

  componentWillUnmount: ->
    document.removeEventListener 'dblclick', @toggleVisibility

  componentWillMount: ->
    # Set the double click handler
    document.addEventListener 'dblclick', @toggleVisibility

    # Set the data source
    @props.socket.on 'connect', =>
      @props.socket.emit 'join_room', {doc_id: @props.doc_id}

    @props.socket.on 'error_msg', @notify
    Reveal.addEventListener 'slidechanged', @propagateSlide

    @props.source.on 'sync', @onSync

    @props.socket.on 'stats', (stats) =>
      if @props.cursor.refine('sync').value == undefined
        @props.cursor.refine('sync').set true

      @props.cursor.refine('stats').set stats

  toggleVisibility: ->
    visibility = @props.cursor.refine('visibility')
    visibility.set !visibility.pendingValue()

  propagateSlide: (e) ->
    # Tells the other clients that they have to
    # update the current slide
    if @props.cursor.refine('passBox', 'masterpass').value and \
        @props.cursor.refine('sync').value
      if e
        slide = {indexh: e.indexh, indexv: e.indexv}
      else
        # Figure out the coords manually
        {h, v} = Reveal.getIndices()
        slide = {indexh: h, indexv: v}

      # Get the position of the master indicator 
      # in fraction of full window width
      slide.indicator_pos = @indicatorPos()

      payload =
        pass: @props.cursor.refine('passBox', 'masterpass').value
        slide: slide
        setter: @props.cursor.refine('id').value
        doc_id: @props.doc_id

      @props.socket.emit 'slide_change', payload

    @checkSync @props.cursor.refine('sync_position').value

  checkSync: (pos) ->
    {h, v} = Reveal.getIndices()

    sync    = @props.cursor.refine('sync')
    visible = @props.indicatorCursor.refine('visible')

    if not sync.value and pos.indexh == h and pos.indexv == v
      sync.set true
      visible.set false

    if sync.value and not @props.cursor.refine('passBox', 'masterpass').value and \
        (pos.indexh != h or pos.indexv != v)

      sync.set false
      visible.set true

  onSync: (data) ->
    sync = @props.cursor.refine('sync')
    if sync.value == undefined
      sync.set true

    @props.cursor.refine('sync_position').set data.slide
    @props.indicatorCursor.refine('position').set data.slide.indicator_pos

    {h, v} = Reveal.getIndices()

    if sync.value and data.slide.setter?.id != @props.cursor.refine('id').value and \
       (h != data.slide.indexh or v != data.slide.indexv)
      Reveal.slide data.slide.indexh, data.slide.indexv

    @checkSync data.slide


  setPassword: (pass) ->
    # Fired when master password is set
    deferred = Q.defer()
    payload =
      pass: pass
      doc_id: @props.doc_id

    @props.socket.emit 'check_pass', payload, (data) =>
      if @props.cursor.refine('sync').value
        cb = (->)
      else
        cb = @propagateSlide

      if data.valid == true
        @savePass pass
        @props.cursor.refine('passBox', 'masterpass').set pass
        @props.cursor.refine('sync').set true
        cb()

        deferred.resolve true
      else
        @notify 'Invalid password'
        deferred.reject 'Invalid password'

    return deferred.promise

  toggleSync: ->
    if not @props.cursor.refine('sync').pendingValue()
      # The sync will be toggled on
      cb = @propagateSlide
      @props.indicatorCursor.refine('visible').set false

      {h, v} = Reveal.getIndices()
      sync = @props.cursor.refine('sync_position').value
      if not @props.cursor.refine('passBox', 'masterpass').value and \
          (h != sync.indexh or v != sync.indexv)
        Reveal.slide sync.indexh, sync.indexv
    else
      # The sync will be toggled off
      cb = ( -> )
      @props.indicatorCursor.refine('visible').set true

    # Negate the sync state, so toggle 
    # from true to false and vice versa
    sync = @props.cursor.refine('sync')
    sync.set !sync.pendingValue
    cb()

  releaseMaster: ->
    @clearPass()
    @props.cursor.refine('passBox', 'masterpass').set undefined

  render: ->
    visibility = @props.cursor.refine('visibility').value
    classes = addons.classSet
      visible: visibility
      hidden: !visibility
      'showjs-settings': true

    (
      <div className={classes}>
        <Button state={@props.cursor.refine('sync').value}
                onClick={@toggleSync}
                classes='sync-btn'
                ontext='Sync on'
                offtext='Sync off'
                />

        <Stats stats={@props.cursor.refine('stats').value} />

        <MasterPassBox
                       cursor={@props.cursor.refine 'passBox'}
                       onPassSet={@setPassword}
                       onMasterRelease={@releaseMaster}
                       />

      </div>
    )
