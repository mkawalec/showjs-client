{Button} = require './components/Button'

module.exports.MasterPassBox = React.createClass
  getInitialState: ->
    return {passEnter: false, visible: true}

  setBtnClicked: ->
    @setState {passEnter: true}

  clear: =>
    @refs.pass.getDOMNode().value = ''

  setPass: ->
    pass = @refs.pass.getDOMNode().value
    @props.onPassSet(pass).then (=> @setState {visible: false}), @clear

  keyUp: (e) ->
    if e.which == 13
      @setPass()

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
  
    if @state.visible
      (
        <div>
          {contents}
        </div>
      )
    else
      null
