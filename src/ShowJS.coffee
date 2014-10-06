{SessionManager}    = require './SessionManager'
{PositionIndicator} = require './PositionIndicator'
{helpersMixin}      = require './helpersMixin'
{passMixin}         = require './passMixin'

{Cursor} = require 'react-cursor'
React    = require 'react'


module.exports.ShowJS = React.createClass
  mixins: [helpersMixin, passMixin]

  getInitialState: ->

    {
      indicator: {
        visible: false
        position: 0
      }
      session: {
        id: @getId()
        stats: {}
        sync_position: {}
        masterpass: @getPass()
        visibility: false
      }
    }

  render: ->
    cursor = Cursor.build @
    indicatorCursor = cursor.refine 'indicator'

    (
      <div className='showjs'>
        <SessionManager doc_id={@props.doc_id}
                        socket={@props.socket}
                        source={@props.source}
                        indicatorCursor={indicatorCursor}
                        cursor={cursor.refine('session')}
                        />

        <PositionIndicator visible={indicatorCursor.refine('visible')}
                           position={indicatorCursor.refine('position')}
                        />
      </div>
    )

