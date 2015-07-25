margin = do
  top: 80
  right: 80
  bottom: 80
  left: 80
height = 500 - margin.left - margin.right
width = 960 - margin.top- margin.right


max = (v1, v2) ->
  return if v1 > v2 then v1 else v2
min = (v1, v2) ->
  return if v1 < v2 then v1 else v2


# append a svg for drawing stock chart
stockGraph = d3.select \.stock-graph
  .append \svg
  .attr "width", width + margin.left + margin.right
  .attr "height", height + margin.top + margin.bottom
  .attr \class, \graph


data = d3.csv \./test.csv, (error, data) ->
  parseDate = d3.time.format '%d-%b-%y' .parse
  data = data.slice 0, 60 .map (d) ->
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
  scaleX = d3.time.scale!.range [0, width] .domain [minDate, maxDate]
  scaleY = d3.scale.linear!.range [height, 0] .domain [minPrice, maxPrice]
  axisX = d3.svg.axis!
    .scale scaleX
    .ticks 10
    .tickFormat d3.time.format '%m/%d'
    .orient \bottom

  axisY = d3.svg.axis!
    .scale scaleY
    .orient \right

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
  stockGraph.selectAll \line.ticks
    .data scaleX.ticks!
    .enter!
    .append \line
    .attr \x1, (d) ->
      return margin.left + scaleX new Date d.toString!
    .attr \x2, (d) ->
      console.log margin.left + scaleX new Date d.toString!
      return margin.left + scaleX new Date d.toString!
    .attr \y1, margin.top
    .attr \y2, margin.top + height
    .attr \stroke, \#ccc


  # draw the line of the ticks of y axis
  stockGraph.selectAll \line.ticks
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


