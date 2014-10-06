{SessionManager}    = require './SessionManager'
{PositionIndicator} = require './PositionIndicator'


module.exports.ShowJS = React.createClass
  getInitialState: ->
    {
      indicatorVisible: false
      indicatorPosition: 0
    }

  toggleIndicatorState: (state) ->
    if state == 'hide'
      @setState {indicatorVisible: false}
    else if state == 'show'
      @setState {indicatorVisible: true}

  propagateIndicator: (position) ->
    @setState {indicatorPosition: position}

  render: ->
    (
      <div className='showjs'>
        <SessionManager addr={@props.addr}
                        doc_id={@props.doc_id}
                        onIndicatorToggle={@toggleIndicatorState}
                        onIndicatorChange={@propagateIndicator}
                        />

        <PositionIndicator visible={@state.indicatorVisible}
                           position={@state.indicatorPosition}
                           />
      </div>
    )

