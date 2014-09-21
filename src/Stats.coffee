module.exports.Stats = React.createClass
  render: ->
    (
      <div>
        <div>Total clients: {@props.stats.total}</div>
        <div>Clients on this document: {@props.stats.this_document}</div>
      </div>
    )
