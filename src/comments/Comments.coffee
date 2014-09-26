module.exports.Comments = React.createClass
  componentDidMount: ->
    document.addEventListener 'mouseup', @addComment

  componentWillUnmount: ->
    document.removeEventListener 'mouseup', @addComment

  getInterestingChildren: (ancestor, range) ->
    start    = range.startContainer.parentElement
    end      = range.endContainer.parentElement

    _.reduce(ancestor.children, ((acc, child) ->
      if acc.add == true and child.contains(end)
        acc.nodes.push child
        acc.add = false

      else if acc.add == true or child.contains(start)
        acc.nodes.push child
        acc.add = true

      acc
    ), {add: false, nodes: []}).nodes

  find_offset: (node, offset) ->
    offset
    # Here we need an implementation of KMP :D

  markNodes: (node, range, type, start_range=0, end_range) ->
    if type == 'mark_whole'
      contents  = node.innerHTML
      end_range ?= contents.length
      start_offset = @find_offset(node, start_range)

      before = contents.substr(0, start_range)
      toWrap = contents.substr(start_range, end_range)
      after  = contents.substr(end_range, contents.length)
      node.innerHTML = before + "<span class='showjs-selection'>#{toWrap}</span>" + after

    else if type == 'start'
      start_node = range.startContainer.parentElement
      if node == start_node
        @markNodes node, range, 'mark_whole', range.startOffset
      else
        _.reduce node.children, (start_passed, child) =>
          if not start_passed and child.contains(start_node)
            start_passed = true
            @markNodes child, range, 'start'
          else if start_passed
            @markNodes child, range, 'mark_whole'
          start_passed
        , false

    else if type == 'end'
      end_node = range.endContainer.parentElement
      if node == end_node
        @markNodes node, range, 'mark_whole', 0, range.endOffset
      else
        _.reduce node.children, (end_reached, child) =>
          if not end_reached and child.contains(end_node)
            @markNodes child, range, 'end'
            end_reached = true
          else if not end_reached
            @markNodes child, range, 'mark_whole'
          end_reached
        , false

  # In order to remove the selection, we need to traverse 
  # the tree again in the same fashion, this time unpacking
  # the values from the wrappers
  # We get the innerHTML of the wrapper and do replaceChild 
  # (thank you DOM API <3)
  #
  # We also need to deal with the parts of the node that are not
  # inside other children. I propose to wrap these inside a span, 
  # if the node has any children, and they will not be missed when
  # iterating the children.


  addComment: ->
    selection = window.getSelection()
    if selection.type == 'Range'
      range    = selection.getRangeAt(0)
      ancestor = range.commonAncestorContainer

      interesting_children = @getInterestingChildren ancestor, range
      # For each child, add spans for the whole child if 
      # we are dealing with the middle nodes and on the inner parts if not
      _.forEach interesting_children, (child, idx, list) =>
        if idx == 0
          @markNodes child, range, 'start'
        else if idx == list.length - 1
          console.log 'the end'
          @markNodes child, range, 'end'
        else
          @markNodes child, range, 'mark_whole'

  render: ->
    (
      <div>
      </div>
    )
