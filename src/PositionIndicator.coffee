module.exports.PositionIndicator = React.createClass
  getInitialState: ->
    {position: 0, show: false}

  componentDidMount: ->
    @props.dispatch.on 'indicator.change', (position) =>
      @setState {position: position}

    @props.dispatch.on 'indicator.show', =>
      @setState {show: true}

    @props.dispatch.on 'indicator.hide', =>
      @setState {show: false}

  render: ->
    if @state.show
      <span style={width: "#{window.innerWidth * @state.position}px"}></span>
    else
      <span/>
