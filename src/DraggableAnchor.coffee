module.exports.DraggableAnchor = React.createClass
  mouseDown: (e) ->
    @start = {}
    @stick_to = 'left'
    @node = @getDOMNode()

    document.addEventListener 'mousemove', @move
    document.addEventListener 'mouseup', @mouseUp

  mouseUp: ->
    document.removeEventListener 'mousemove', @move
    document.removeEventListener 'mouseup', @mouseUp

  nonNegative: (val) -> if val < 0 then 0 else val

  setCoord: (x, y) ->
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
    # TODO: These are broken:D
    @start.left ?= e.x - @node.offsetLeft
    @start.top ?= e.y - @node.offsetTop

    if @node.offsetLeft == 0 and @node.offsetTop == 0
      # Top-left corner

      if e.x - @start.left > e.y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'left'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop == 0
      # Top-right corner

      if @node.offsetLeft + @start.left - e.x > e.y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'right'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-right corner

      if @node.offsetLeft + @start.left - e.x > @node.offsetTop + @start.top - e.y
        @stick_to = 'bottom'
      else
        @stick_to = 'right'
    else if @node.offsetLeft == 0 and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-left corner

      if @node.offsetTop + @start.top - e.y > e.x - @start.left
        @stick_to = 'left'
      else
        @stick_to = 'bottom'

    @setCoord e.x - @start.left, e.y - @start.top

  render: ->
    (
      <div className='draggable-anchor'>
        <div className='indicator' onMouseDown={@mouseDown} />
        <div className='container'/>
      </div>
    )
