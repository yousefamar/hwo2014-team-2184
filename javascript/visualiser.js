var http = require('http');
var open = require('open');
var shoe = require('shoe');
var ecstatic = require('ecstatic')('visualiser');

var lastStream = null;

module.exports = {

  init: function (port) {
    port = port || 8000;
    
    var server = http.createServer(ecstatic);
    server.listen(port);
    
    var sock = shoe(function (stream) {
      lastStream = stream;

      stream.on('end', function () {
      });

      //stream.pipe(process.stdout, { end : false });
    });
    sock.install(server, '/racedata');

    open('http://localhost:'+port+'/index.html');
  },

  update: function(data) {
    lastStream && lastStream.write(JSON.stringify(data));
  }
};