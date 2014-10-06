React = require 'react'

module.exports.PositionIndicator = React.createClass
  render: ->
    indicator = <span/>
    if @props.visible.value
      indicator = <span style={width: "#{window.innerWidth * @props.position.value}px"}></span>

    <div className='showjs-indicator'>
      {indicator}
    </div>
