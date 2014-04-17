var http = require('http');
var fs = require('fs');
var open = require('open');
var io = require('socket.io');

var socket = null;

module.exports = {

  init: function () {
    port = 8000;

    http.createServer(function (req, res) {
      // Super dangerous, plase look away
      if (req.url !== '/favicon.ico')
        fs.createReadStream('visualiser'+req.url).pipe(res);
    }).listen(port);

    io = io.listen(port+1);
    io.sockets.on('connection', function (sock) {
      console.log('Connected to client');
      socket = sock;
    });

    open('http://localhost:'+port+'/index.html');
  },

  update: function(data) {
    // TODO: Make sure init'd

    socket && socket.emit('data', data);
  }
};