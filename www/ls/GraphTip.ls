class ig.GraphTip
  (@parentElement) ->
    @element = @parentElement.append \div
      ..attr \class "graph-tip"
    @content = @element.append \div
      ..attr \class \content
    @arrow = @element.append \div
      ..attr \class \arrow

  display: (x, y, content) ->
    @element.classed \active yes
    @content.html content
    width = @element.node!clientWidth
    height = @element.node!clientHeight
    xPosition = x
    yPosition = y
    left = xPosition - width / 2
    offset = 0
    if left < 0
      offset = left
      left = 0
    if left + width > window.innerWidth
      offset = left + width - window.innerWidth
      left = window.innerWidth - width
    top = yPosition - height
    @element.classed \out top < 0 or left < 0
    top = 0 if top < 0
    left = 0 if left < 0
    @element
      ..style \left left + "px"
      ..style \top top + "px"
    @arrow.style \left offset + "px"

  hide: ->
    @element.classed \active no
