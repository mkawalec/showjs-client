React = require 'react/addons'
{div} = React.DOM

module.exports.Comment = React.create-class do
  render: ->
    div {class-name: 'comment'}
