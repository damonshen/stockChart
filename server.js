// process.env.PORT for Heroku
var port = process.env.PORT || 3000; 
var connect = require('connect');
var express = require('express');

var app = express()
  .use(connect.static('app'))
  .use(connect.static('.tmp'))
  .use(connect.directory('app'))
.listen(port)
  .on('listening', function () {
    console.log('Started connect web server on http://localhost:' + port);
  });
