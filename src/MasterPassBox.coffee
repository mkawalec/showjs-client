{Button} = require './components/Button'
React    = require 'react'

module.exports.MasterPassBox = React.createClass
  setBtnClicked: ->
    @props.cursor.refine('inputVisible').set true

  clear: ->
    @refs.pass.getDOMNode().value = ''

  setPass: ->
    pass = @refs.pass.getDOMNode().value
    @props.onPassSet(pass).then (->), @clear

  keyUp: (e) ->
    if e.which == 13
      @setPass()

  releaseMaster: ->
    @props.cursor.refine('inputVisible').set false
    @props.cursor.refine('passEntered').set false
    @props.onMasterRelease()

  render: ->
    contents = []
    if @props.cursor.refine('inputVisible').value
      contents.push <input type='password'
                           ref='pass'
                           onKeyUp={@keyUp}
                           autoFocus
                           />

      contents.push <Button ontext='Submit'
                          onClick={@setPass}
                          />
    else
      contents = <Button ontext='Set master password'
                         onClick={@setBtnClicked} />
  
    # Actually place the contents on the page. Or don't
    # if the password was already entered
    if not @props.cursor.refine('masterpass').value
      (
        <div>
          {contents}
        </div>
      )
    else
      <Button ontext='Release master rights'
              onClick={@releaseMaster} />
