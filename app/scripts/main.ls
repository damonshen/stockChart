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
  data = data.slice 0, 30 .map (d) ->
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
    .ticks d3.time.days, 5
    .tickFormat d3.time.format '%m/%d'
    .orient \bottom

  axisY = d3.svg.axis!
    .scale scaleY
    .ticks 10
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
      return if d.open > d.close then \red else \green



