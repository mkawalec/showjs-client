module.exports.PositionIndicator = React.createClass
  render: ->
    indicator = <span/>
    if @props.visible
      indicator = <span style={width: "#{window.innerWidth * @props.position}px"}></span>

    <div className='showjs-indicator'>
      {indicator}
    </div>
