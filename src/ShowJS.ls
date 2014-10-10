{Cursor} = require 'react-cursor'
React    = require 'react/addons'

{div} = React.DOM

{Session-manager}    = require './SessionManager'
{Position-indicator} = require './PositionIndicator'
{helpers-mixin}      = require './helpersMixin'
{pass-mixin}         = require './passMixin'


module.exports.ShowJS = React.create-class do
  mixins: [helpers-mixin, pass-mixin]

  getInitialState: ->
    indicator:
      visible: false
      position: 0

    session:
      id: @get-id!
      stats: {}
      sync-position: {}
      visibility: false
      pass-box:
        input-visible: false
        pass-entered: false
        masterpass: @get-pass!

  component-will-mount: ->
    cursor = Cursor.build @

    do
      # Join a correct room
      <~! @props.socket.on 'connect'
      @props.socket.emit 'join_room', {doc_id: @props.doc_id}

    do
      # React to stats received
      stats <~! @props.socket.on 'stats'
      if cursor.refine \session \sync .value == undefined
        cursor.refine \session \sync .set true

      cursor.refine \session \stats .set stats

  render: ->
    cursor = Cursor.build @

    div className: \showjs,
      Session-manager do
        doc_id: @props.doc_id
        socket: @props.socket
        source: @props.source
        indicator-cursor: cursor.refine \indicator
        cursor: cursor.refine \session

      Position-indicator do
        visible:  cursor.refine \indicator, \visible
        position: cursor.refine \indicator, \position
