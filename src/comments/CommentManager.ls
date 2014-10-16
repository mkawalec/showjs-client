React = require 'react/addons'
{div} = React.DOM
{map} = require 'prelude-ls'

{Comment} = require './Comment'
{ShowComment} = require './models'
{store-mixin} = require './storeMixin'

module.exports.Comment-manager = React.create-class do
  mixins: [store-mixin]

  click-start: ->
    @props.cursor.refine \mouseTimeout .set do
      set-timeout @add-comment, @props.cursor.refine(\mouseClickTime).value

  add-comment: ->
    console.log 'adding commnet'

  click-end: ->
    timeout-value = @props.cursor.refine \mouseTimeout .pending-value!
    if timeout-value?
      clear-timeout timeout-value
      @props.cursor.refine \mouseTimeout .set undefined

  component-did-mount: ->
    document.add-event-listener 'mouseup', @click-end

  component-will-unmount: ->
    document.remove-event-listener 'mouseup', @click-end

  render: ->
    div {class-name: 'showjs-comment-manager', on-mouse-down: @click-start}

