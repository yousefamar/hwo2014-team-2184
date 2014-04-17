VIS = {};

VIS.main = function () {
  var socket = io.connect('http://localhost:8001');
  socket.on('data', function (data) {
    console.log(data);
  });
};