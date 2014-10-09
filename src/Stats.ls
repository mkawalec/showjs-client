React = require 'react/addons'

{div} = React.DOM

module.exports.Stats = React.create-class do
  render: ->
    div null,
      div null, "Total clients: #{@props.stats.total}"
      div null, "Clients on this document: #{@props.stats.this_document}"
