React = require 'react/addons'

{div, span} = React.DOM

module.exports.PositionIndicator = React.createClass do
  render: ->
    div {className: 'showjs-indicator'},
      span do
        if @props.visible.value is true
          style:
            width: "#{window.innerWidth * @props.position.value}px"
        else
          null
        null
