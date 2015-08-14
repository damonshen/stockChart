margin = do
  top: 40
  right: 80
  bottom: 40
  left: 80
height = 500 - margin.left - margin.right
width = 960 - margin.top- margin.right
textBlockWidth = width / 8


max = (v1, v2) ->
  return if v1 > v2 then v1 else v2
min = (v1, v2) ->
  return if v1 < v2 then v1 else v2

# append a svg for showing the stock information
stockInfo = d3.select \.stock-graph
  .append \svg
  .attr "width", width + margin.left + margin.right
  .attr "height", 50
  .attr \class, \stock-info


intializeStockInfo = (textSvg)->

  textSvg.append \text
    .attr \class, \text-info
    .attr \x, margin.left
    .attr \y, 30
    .text \Open:

  textSvg.append \text
    .attr \class, 'open'
    .attr \x, margin.left + 1 * textBlockWidth
    .attr \y, 30

  textSvg.append \text
    .attr \class, \text-info
    .attr \x, margin.left + 2 * textBlockWidth
    .attr \y, 30
    .text \High:

  textSvg.append \text
    .attr \class, 'high'
    .attr \x, margin.left + 3 * textBlockWidth
    .attr \y, 30

  textSvg.append \text
    .attr \class, \text-info
    .attr \x, margin.left + 4 * textBlockWidth
    .attr \y, 30
    .text \Low:

  textSvg.append \text
    .attr \class, 'low'
    .attr \x, margin.left + 5 * textBlockWidth
    .attr \y, 30

  textSvg.append \text
    .attr \class, \text-info
    .attr \x, margin.left + 6 * textBlockWidth
    .attr \y, 30
    .text \Close:

  textSvg.append \text
    .attr \class, 'close'
    .attr \x, margin.left + 7 * textBlockWidth
    .attr \y, 30

showStockPrice = (d, textSvg) ->
  color = if d.open < d.close then \red else \green

  textSvg.select \text.open
    .attr \fill, color
    .text d.open

  textSvg.select \text.high
    .attr \fill, color
    .text d.high

  textSvg.select \text.low
    .attr \fill, color
    .text d.low

  textSvg.select \text.close
    .attr \fill, color
    .text d.close



intializeStockInfo stockInfo

data = d3.csv \./test.csv, (error, data) ->
  parseDate = d3.time.format '%d-%b-%y' .parse
  data = data.slice 0, 80 .map (d) ->
    return do
      date: parseDate(d.Date)
      open: +d.Open
      high: +d.High
      low: +d.Low
      close: +d.Close
      volume: +d.Volume
  console.log data


  maxDate = d3.max data, (d) ->
    d.date
  minDate = d3.min data, (d) ->
    d.date
  minPrice = d3.min data, (d) ->
    d.low
  maxPrice = d3.max data, (d) ->
    d.high
  console.log maxDate + '\n' + minDate

  data.sort (a, b) ->
    dateA = new Date a.date
    dateB = new Date b.date
    return dateA - dateB

  xRange = [0 to width by width / (data.length - 1)]
  if xRange.length < data.length
    xRange.push width

  console.log xRange.length

  scaleX = d3.time.scale!
    .range xRange
    .domain data.map (d) ->
      new Date d.date
  scaleY = d3.scale.linear!.range [height, 0] .domain [minPrice, maxPrice]

  axisX = d3.svg.axis!
    .scale scaleX
    .ticks 5
    .tickFormat d3.time.format '%m/%d'
    .orient \bottom

  axisY = d3.svg.axis!
    .scale scaleY
    .orient \right


  # append a svg for drawing stock chart
  stockGraph = d3.select \.stock-graph
    .append \svg
    .attr "width", width + margin.left + margin.right
    .attr "height", height + margin.top + margin.bottom
    .attr \class, \graph
    .append("g")

  # draw x axis
  stockGraph.append \g
    .attr do
      'transform': 'translate(' + margin.left + \, + (height + margin.top) + \)
    .attr \class, 'axis x'
    .call axisX

  # draw y axis
  stockGraph.append \g
    .attr do
      'transform': 'translate(' + (width + margin.left) + \, + margin.top + ')'
    .attr \class, 'axis y'
    .call axisY

  # draw the line of the ticks of x axis
  xticks = stockGraph.selectAll \line.xticks
    .data scaleX.ticks 5
    .enter!
    .append \line
    .attr \x1, (d) ->
      return margin.left + scaleX new Date d.toString!
    .attr \x2, (d) ->
      return margin.left + scaleX new Date d.toString!
    .attr \y1, margin.top
    .attr \y2, margin.top + height
    .attr \stroke, \#ccc


  # draw the line of the ticks of y axis
  yticks = stockGraph.selectAll \line.yticks
    .data scaleY.ticks!
    .enter!
    .append \line
    .attr \x1, margin.left
    .attr \x2, margin.left + width
    .attr \y1, (d) ->
      return margin.top + scaleY d
    .attr \y2, (d) ->
      return margin.top + scaleY d
    .attr \stroke, \#ccc


  # draw the rectangle of the candlestick
  stockGraph.selectAll \rect
    .data data
    .enter!
    .append \rect
    .attr \x, (d) ->
      offset = 0.25 * width / data.length
      margin.left - offset + scaleX new Date d.date
    .attr \y, (d) ->
      rectHeight = max d.open, d.close
      return margin.top + scaleY rectHeight
    .attr \width, 0.5 * width / data.length
    .attr \height, (d) ->
      start = scaleY (min d.open, d.close)
      end = scaleY (max d.open, d.close)
      return start - end
    .on \mouseover, (d) ->
      showStockPrice d, stockInfo
    .attr \fill, (d) ->
      return if d.open > d.close then \green else \red

  # draw the high and low line
  # use .stem for specific the line in the svg
  stockGraph.selectAll \line.stem
    .data data
    .enter!
    .append \line
    .attr \x1, (d) ->
      return margin.left + scaleX new Date d.date
    .attr \x2, (d) ->
      return margin.left + scaleX new Date d.date
    .attr \y1, (d) ->
      return margin.top + scaleY d.high
    .attr \y2, (d) ->
      return margin.top + scaleY d.low
    .attr \stroke, (d) ->
      return if d.open > d.close then \green else \red
    .on \mouseover, (d) ->
      showStockPrice d, stockInfo

  draw = ->
    console.log \zoom
    stockGraph.select \.axis.x .call axisX
    stockGraph.select \.axis.y .call axisY
    stockGraph.select \line .attr \d, xticks

  zoom = d3.behavior.zoom!
    .x scaleX
    .y scaleY
    .scaleExtent [0.5, 1]
    .on \zoom, draw

  stockGraph.call zoom
  /*
  # zoom construct
  zoom = d3.behavior.zoom!
    .on \zoom, draw

  # add a rect on the graph for detect zoomimg
  stockGraph.append \rect
    .attr \class, \pane
    .attr \width, width + 2 * margin.left
    .attr \height, height + margin.top + margin.bottom
    .call zoom

  zoom.x scaleX
  draw!
  */
  # redraw the graph when zooming
