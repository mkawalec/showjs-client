{Button} = require './components/Button'

module.exports.MasterPassBox = React.createClass
  getInitialState: ->
    return {passEnter: false}

  setBtnClicked: ->
    @setState {passEnter: true}

  clear: ->
    @refs.pass.getDOMNode().value = ''

  setPass: ->
    pass = @refs.pass.getDOMNode().value
    @props.onPassSet(pass).then (->), @clear

  keyUp: (e) ->
    if e.which == 13
      @setPass()

  releaseMaster: ->
    @setState {passEnter: false, passEntered: false}
    @props.onMasterRelease()

  render: ->
    contents = []
    if @state.passEnter
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
  
    if not @props.pass
      (
        <div>
          {contents}
        </div>
      )
    else
      <Button ontext='Release master rights'
              onClick={@releaseMaster} />
