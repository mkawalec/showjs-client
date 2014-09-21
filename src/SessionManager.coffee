{Button}       = require './components/Button'
{helpersMixin} = require './helpersMixin'

module.exports.SessionManager = React.createClass
  mixins: [helpersMixin]

  getInitialState: ->
    return {sync: false, id: @get_id()}

  componentWillMount: ->
    socket = io @props.addr
    socket.join @props.doc_id

    socket.emit 'sync_me', {doc_id: @props.doc_id}

    socket.on 'sync', (data) ->
      if data.slide.setter?.id != @state.id
        Reveal.slide data.slide.indexh, data.slide.indexv

      Reveal.addEventListener 'slidechanged', (e) =>
        if @state.masterpass
          payload =
            pass: @state.masterpass
            slide: {indexh: e.indexh, indexv: e.indexv}
            setter: @state.id
            doc_id: @props.doc_id

          socket.emit 'slide_change', payload

  setPassword: ->
    pass = @refs.masterpass.getDOMNode().value
    payload =
      pass: pass
      doc_id: @props.doc_id

    socket.emit 'check_pass', payload, (data) ->
      if data.valid == true
        @setState {masterpass: pass}
      else
        @notify 'Invalid password'

  render: ->
    (
      <div/>
    )
