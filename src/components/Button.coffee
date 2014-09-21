module.exports.Button = React.createClass
  render: ->
    classes = 'btn '
    if @props.state or @props.state == undefined
      text = @props.ontext
      classes += 'on '
    else
      classes += 'off '
      text = @props.offtext

    (
      <button onClick={@props.onClick}
              className={classes + (@props.classes ? '')}>
                {text}
      </button>
    )
