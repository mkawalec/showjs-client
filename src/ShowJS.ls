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
