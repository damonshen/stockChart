// Generated by LiveScript 1.3.1
(function(){
  var margin, height, width, stockGraph, data;
  margin = {
    top: 80,
    right: 80,
    bottom: 80,
    left: 80
  };
  height = 500 - margin.left - margin.right;
  width = 960 - margin.top - margin.right;
  stockGraph = d3.select('.stock-graph').append('svg').attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).attr('class', 'graph');
  data = d3.csv('./test.csv', function(error, data){
    var parseDate, time, maxDate, minDate, scaleX, scaleY, axisX, axisY;
    parseDate = d3.time.format('%d-%b-%y').parse;
    data = data.slice(0, 10).map(function(d){
      return {
        date: parseDate(d.Date),
        open: +d.Open,
        high: +d.High,
        low: +d.Low,
        close: +d.Close,
        volume: +d.Volume
      };
    });
    console.log(data);
    time = d3.time.format('%d-%b-%y').parse('9-Jun-14');
    maxDate = d3.max(data, function(d){
      return d.date;
    });
    minDate = d3.min(data, function(d){
      return d.date;
    });
    console.log(maxDate + '\n' + minDate);
    scaleX = d3.time.scale().range([margin.left, width]).domain([minDate, maxDate]);
    scaleY = d3.scale.linear().range([height + margin.top, margin.top]);
    axisX = d3.svg.axis().scale(scaleX).ticks(d3.time.days, 1).tickFormat(d3.time.format('%m/%d')).orient('bottom');
    axisY = d3.svg.axis().scale(scaleY).orient('right');
    stockGraph.append('g').attr({
      'transform': 'translate(0,' + (height + margin.top) + ')'
    }).attr('class', 'axis x').call(axisX);
    return stockGraph.append('g').attr({
      'transform': 'translate(' + width + ',0)'
    }).attr('class', 'axis y').call(axisY);
  });
}).call(this);
