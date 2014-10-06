{SessionManager}    = require './SessionManager'
{PositionIndicator} = require './PositionIndicator'
{Cursor}            = require 'react-cursor'
React               = require 'react'


module.exports.ShowJS = React.createClass
  getInitialState: ->
    {
      indicator: {
        visible: false
        position: 0
      }
    }

  toggleIndicatorState: (state) ->
    if state == 'hide'
      @setState {indicatorVisible: false}
    else if state == 'show'
      @setState {indicatorVisible: true}

  propagateIndicator: (position) ->
    @setState {indicatorPosition: position}

  render: ->
    cursor = Cursor.build @
    indicatorCursor = cursor.refine 'indicator'

    (
      <div className='showjs'>
        <SessionManager addr={@props.addr}
                        doc_id={@props.doc_id}
                        onIndicatorToggle={@toggleIndicatorState}
                        onIndicatorChange={@propagateIndicator}
                        indicatorCursor={indicatorCursor}
                        />

        <PositionIndicator visible={indicatorCursor.refine('visible')}
                           position={indicatorCursor.refine('position')}
                        />
      </div>
    )

