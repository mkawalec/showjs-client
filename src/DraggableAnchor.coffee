module.exports.DraggableAnchor = React.createClass
  move_cb: ( -> )

  mouseDown: (e) ->
    @start = {}
    @stick_to = 'left'
    @node = @getDOMNode()

    @move_cb = _.throttle @move, 50
    document.addEventListener 'mousemove', @move_cb
    document.addEventListener 'mouseup', @mouseUp

  mouseUp: ->
    document.removeEventListener 'mousemove', @move_cb
    document.removeEventListener 'mouseup', @mouseUp

  nonNegative: (val) -> if val < 0 then 0 else val

  setCoord: (e) ->
    {x, y} = e
    if x + @node.offsetWidth > window.innerWidth
      x = window.innerWidth - @node.offsetWidth
    if y + @node.offsetHeight > window.innerHeight
      y = window.innerHeight - @node.offsetHeight

    if @stick_to == 'left'
      @node.setAttribute 'style', "top: #{@nonNegative y}px"
    else if @stick_to == 'top'
      @node.setAttribute 'style', "left: #{@nonNegative x}px"
    else if @stick_to == 'right'
      @node.setAttribute 'style', "top: #{@nonNegative y}px; right:0;left:auto"
    else if @stick_to == 'bottom'
      @node.setAttribute 'style', "left: #{@nonNegative x}px; bottom:0;top:auto"


  move: (e) ->
    e.stopPropagation()
    @start.left ?= e.x
    @start.top ?= e.y

    if @node.offsetLeft == 0 and @node.offsetTop == 0
      # Top-left corner

      if e.x - @start.left > e.y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'left'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop == 0
      # Top-right corner

      if window.innerWidth - e.x - @start.left > e.y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'right'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-right corner

      if window.innerWidth - e.x - @start.left > window.innerHeight - e.y - @start.top
        @stick_to = 'bottom'
      else
        @stick_to = 'right'
    else if @node.offsetLeft == 0 and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-left corner

      if window.innerHeight - e.y - @start.top > e.x - @start.left
        @stick_to = 'left'
      else
        @stick_to = 'bottom'

    @setCoord e

  render: ->
    (
      <div className='draggable-anchor'>
        <div className='indicator' onMouseDown={@mouseDown} />
        <div className='container'/>
      </div>
    )
