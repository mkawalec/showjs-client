{Button} = require './components/Button'

module.exports.MasterPassBox = React.createClass
  getInitialState: ->
    return {passEnter: false, passEntered: false}

  setBtnClicked: ->
    @setState {passEnter: true}

  clear: ->
    console.log 'clr called'
    @refs.pass.getDOMNode().value = ''

  setPass: ->
    console.log 'set called'
    pass = @refs.pass.getDOMNode().value
    @props.onPassSet(pass).then (=> @setState {passEntered: true}), (->console.log(arguments))
    true

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
  
    if not @state.passEntered
      (
        <div>
          {contents}
        </div>
      )
    else
      <Button ontext='Release master rights'
              onClick={@releaseMaster} />
