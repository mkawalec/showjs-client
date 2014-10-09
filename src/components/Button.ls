React = require 'react/addons'

{button} = React.DOM

module.exports.Button = React.create-class do
  render: ->
    classes = 'btn '
    if @props.state or @props.state == undefined
      text = @props.ontext
      classes += 'on '
    else
      classes += 'off '
      text = @props.offtext

    button {on-click: @props.on-click, class-name: classes + (@props.classes ? '')}, text
