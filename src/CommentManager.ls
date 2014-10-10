React = require 'react/addons'
{div} = React.DOM
{map} = require 'prelude-ls'

{Comment} = require './Comment'

module.exports.Comment-manager = React.create-class do
  render: ->
    comments = @props.cursor.refine @props.current-slide .value ? [] |> map ->
      Comment {data: it}

    div {class-name: 'comment-manager'}, comments

