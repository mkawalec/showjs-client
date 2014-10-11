{Cursor} = require 'react-cursor'
React    = require 'react/addons'

{div} = React.DOM

{Session-manager}    = require './SessionManager'
{Position-indicator} = require './PositionIndicator'
{helpers-mixin}      = require './helpersMixin'
{pass-mixin}         = require './passMixin'
{Comment-manager}    = require './CommentManager'

{flatten, map, each} = require 'prelude-ls'


module.exports.ShowJS = React.create-class do
  mixins: [helpers-mixin, pass-mixin]

  getInitialState: ->
    indicator:
      visible: false
      position: 0

    comments:
      comments: {}
      mouse-timeout: undefined
      mouse-click-time: 2000

    session:
      id: @get-id!
      stats: {}
      sync-position: {}
      visibility: false
      current-slide: ''
      pass-box:
        input-visible: false
        pass-entered: false
        masterpass: @get-pass!

  comment-added: (cursor, cb) ->
    # Continues if the comment wasn't yet added
    all-ids = cursor.refine \comments .pending-value!
      |> map (-> it.id)
      |> map
      |> flatten

    (comment) ->
      if not elem-index comment.id, all-ids
        cb comment

  component-will-mount: ->
    cursor = Cursor.build @

    do
      # Join a correct room
      <~! @props.socket.on 'connect'
      @props.socket.emit 'join_room', {doc_id: @props.doc_id}

    do
      # React to stats received
      stats <~! @props.socket.on 'stats'
      if cursor.refine \session \sync .value == undefined
        cursor.refine \session \sync .set true

      cursor.refine \session \stats .set stats

    do
      # When a comment is received
      comments <~! @props.socket.on 'comment'
      comments |> each @comment-added cursor, (comment) ->
        comments-store = cursor.refine \comments \comments
        if not comments-store.refine comment.coords .pending-value!?
          comments-store.refine comment.coords .set []

        if not comment.in_reply_to?
          comments-store.refine comment.coords .pending-value!push comment


  render: ->
    cursor = Cursor.build @

    div className: \showjs,
      Session-manager do
        doc_id: @props.doc_id
        socket: @props.socket
        source: @props.source
        indicator-cursor: cursor.refine \indicator
        cursor: cursor.refine \session

      Position-indicator do
        visible:  cursor.refine \indicator, \visible
        position: cursor.refine \indicator, \position

      Comment-manager do
        cursor: cursor.refine \comments
        current-slide: cursor.refine \session \currentSlide .value
