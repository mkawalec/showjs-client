{Button} = require './components/Button'
React    = require 'react/addons'

{div, input} = React.DOM

module.exports.Master-pass-box = React.create-class do

  set-btn-clicked: ->
    @props.cursor.refine \input-visible .set true

  set-pass: ->
    # Sets the password, and clears the password field,
    # if the password was incorrect
    pass-node = @refs.pass.getDOMNode!
    pass = pass-node.value

    do
      <-! @props.on-pass-set pass .fail
      pass-node.value = ''

  # Reacts to the keyUp event
  key-up: -> if it.which == 13 then @set-pass!

  # Called to remove master rights from the current client
  release-master: ->
    @props.cursor.refine \input-visible .set false
    @props.cursor.refine \pass-entered .set false
    @props.on-master-release!

  render: ->
    if not @props.cursor.refine \masterpass .value?
      div null, do
        if @props.cursor.refine \inputVisible .value?
          * input {type: \password, ref: \pass, on-key-up: @key-up, autoFocus: true}
            Button {ontext: \Submit, on-click: @set-pass}
        else
          Button {ontext: 'Set master password', on-click: @set-btn-clicked}
    else
      Button {ontext: 'Release master rights', on-click: @release-master}
