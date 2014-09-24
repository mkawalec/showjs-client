module.exports.DraggableAnchor = React.createClass
  componentWillMount: ->
    # Create a div that will cover the whole page, 
    # so that we can intercept mousemove for everything
    @interceptor = document.createElement 'div'
    @interceptor.className = 'showjs-interceptor'

  mouseDown: (e) ->
    console.log 'down fired', e
    @start = {}
    @stick_to = 'left'
    @node = @getDOMNode()

    document.querySelector('body').appendChild @interceptor

    @interceptor.addEventListener 'mousemove', @move
    @node.addEventListener 'mousemove', @move

    document.addEventListener 'touchmove', @move
    document.addEventListener 'mouseup', @mouseUp
    document.addEventListener 'touchend', @mouseUp

  mouseUp: ->
    @interceptor.removeEventListener 'mousemove', @move
    document.querySelector('body').removeChild @interceptor

    @node.removeEventListener 'mousemove', @move
    document.removeEventListener 'touchmove', @move
    document.removeEventListener 'mouseup', @mouseUp
    document.removeEventListener 'touchend', @mouseUp

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

    {x, y} = e
    x ?= e.touches[0].clientX
    y ?= e.touches[0].clientY
    @start.left ?= x - @node.offsetLeft
    @start.top ?= y - @node.offsetTop

    if @node.offsetLeft == 0 and @node.offsetTop == 0
      # Top-left corner

      if x - @start.left > y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'left'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop == 0
      # Top-right corner

      if @node.offsetLeft + @start.left - x > y - @start.top
        @stick_to = 'top'
      else
        @stick_to = 'right'
    else if @node.offsetLeft + @node.offsetWidth >= window.innerWidth and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-right corner

      if @node.offsetLeft + @start.left - x > @node.offsetTop + @start.top - y
        @stick_to = 'bottom'
      else
        @stick_to = 'right'
    else if @node.offsetLeft == 0 and \
        @node.offsetTop + @node.offsetHeight >= window.innerHeight
      # Bottom-left corner

      if @node.offsetTop + @start.top - y > x - @start.left
        @stick_to = 'left'
      else
        @stick_to = 'bottom'

    @setCoord x - @start.left, y - @start.top

  render: ->
    (
      <div className='draggable-anchor'>
        <div className='indicator' onMouseDown={@mouseDown} onTouchStart={@mouseDown}/>
        <div className='container'/>
      </div>
    )
