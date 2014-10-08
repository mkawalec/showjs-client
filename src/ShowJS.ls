
{Cursor} = require 'react-cursor'
React    = require 'react/addons'

{div} = React.DOM

{PositionIndicator} = require './PositionIndicator'

module.exports.ShowJS = React.create-class do
  getInitialState: ->
    indicator:
      visible: false
      position: 0

    session:
      id: 1
      stats: {}
      sync-position: {}
      visibility: false
      passBox:
        input-visible: false
        pass-entered: false
        masterpass: undefined

  render: ->
    cursor = Cursor.build @
    div className: \showjs,
      PositionIndicator do
        visible:  cursor.refine \indicator, \visible
        position: cursor.refine \indicator, \position
