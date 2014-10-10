{Button}          = require './components/Button'
{Stats}           = require './Stats'
{Master-pass-box} = require './MasterPassBox'
{helpers-mixin}   = require './helpersMixin'
{pass-mixin}      = require './passMixin'

React = require 'react/addons'
{div} = React.DOM

module.exports.Session-manager = React.create-class do
  mixins: [helpers-mixin, pass-mixin]

  # Remove the 'admin panel showing' watcher
  component-will-unmount: ->
    document.remove-event-listener 'dblclick', @toggle-visibility

  # Adds all the event listeners
  component-will-mount: ->
    document.add-event-listener 'dblclick', @toggle-visibility

    # Just notify about the error
    @props.socket.on 'error_msg', @notify
    Reveal.add-event-listener 'slidechanged', @propagate-slide
    @props.source.on 'sync', @on-sync

  toggle-visibility: ->
    visibility = @props.cursor.refine \visibility
    visibility.set !visibility.pendingValue!

  propagate-slide: ->
    if it
      # If this function was fired by a change event, pull
      # the current coords from the event
      slide = {indexh: it.indexh, indexv: it.indexv}
    else
      # Otherwise, determine the indices manually
      {h, v} = Reveal.get-indices!
      slide = {indexh: h, indexv: v}

    # Tells the other clients that they have to update
    # the currently displayed slide
    if @props.cursor.refine \passBox, \masterpass .value and \
        @props.cursor.refine \sync .pending-value!

      # Get the position of the master indicator
      slide.indicator-pos = @indicator-pos!
      payload =
        pass: @props.cursor.refine \passBox \masterpass .value
        slide: slide
        setter: @props.cursor.refine \id .value
        doc_id: @props.doc_id

      @props.socket.emit 'slide_change', payload

    # Update the current slide
    @props.cursor.refine \currentSlide .set @get-slide-id slide

    # We want to check if we are still in sync after this change happened
    @check-sync(@props.cursor.refine \syncPosition .value)

  check-sync: (pos) ->
    {h, v} = Reveal.getIndices!

    sync    = @props.cursor.refine \sync
    indicator-visible = @props.indicator-cursor.refine \visible

    if not sync.value and pos.indexh == h and pos.indexv == v
      # If we are not in sync, but arrived on the same slide as the master
      sync.set true
      indicator-visible.set false

    if sync.value and not @props.cursor.refine \passBox, \masterpass .value and \
        (pos.indexh != h or pos.indexv != v)

      # If we went out of sync
      sync.set false
      indicator-visible.set true

  on-sync: ->
    # React to a sync event from the server
    sync = @props.cursor.refine \sync
    if sync.value == undefined then sync.set true

    @props.cursor.refine \syncPosition .set it.slide
    @props.indicator-cursor.refine \position .set it.slide.indicator-pos

    {h, v} = Reveal.getIndices!

    if sync.value and it.slide.setter?.id != @props.cursor.refine \id .value and \
        (h != it.slide.indexh or v != it.slide.indexv)
      Reveal.slide it.slide.indexh, it.slide.index

    @check-sync it.slide

  set-password: ->
    # Sets the master password
    deferred = Q.defer!
    payload =
      pass: it
      doc_id: @props.doc_id

    do
      data <~! @props.socket.emit 'check_pass', payload
      if data.valid == true
        @save-pass it
        @props.cursor.refine \passBox, \masterpass .set it
        @props.cursor.refine \sync .set true

        if not @props.cursor.refine \sync .value
          @propagate-slide!
        deferred.resolve true
      else
        @notify 'Invalid password'
        deferred.reject 'Invalid password'

    deferred.promise

  toggle-sync: ->
    # Handles the press of the sync toggle button
    if not @props.cursor.refine \sync .pendingValue!
      # The sync will be toggled on
      @props.cursor.refine \sync .set true
      @props.indicator-cursor.refine \visible .set false

      {h, v} = Reveal.getIndices!
      sync-position = @props.cursor.refine \syncPosition .value
      if not @props.cursor.refine \passBox, \masterpass .value and \
          (h != sync-position.indexh or v != sync-position.indexv)
        Reveal.slide sync-position.indexh, sync-position.indexv

      @propagate-slide!
    else
      @props.cursor.refine \sync .set false
      @props.indicator-cursor.refine \visible .set \true

  render: ->
    visibility = @props.cursor.refine \visibility .value
    classes = React.addons.class-set do
      visible: visibility
      hidden: !visibility
      'showjs-settings': true

    div {class-name: classes},
      Button do
        state: @props.cursor.refine \sync .value
        on-click: @toggle-sync
        classes: 'sync-btn'
        ontext: 'Sync on'
        offtext: 'Sync off'

      Stats {stats: @props.cursor.refine \stats .value}

      Master-pass-box do
        cursor: @props.cursor.refine \passBox
        on-pass-set: @set-password
        on-master-release: @release-master
