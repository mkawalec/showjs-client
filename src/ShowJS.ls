{Cursor} = require 'react-cursor'
React    = require 'react/addons'

{div} = React.DOM

{Position-indicator} = require './PositionIndicator'
{helpers-mixin}      = require './helpersMixin'
{pass-mixin}         = require './passMixin'


module.exports.ShowJS = React.create-class do
  mixins: [helpers-mixin, pass-mixin]

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
      Position-indicator do
        visible:  cursor.refine \indicator, \visible
        position: cursor.refine \indicator, \position
