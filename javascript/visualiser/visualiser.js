VIS = {};

VIS.main = (function () {
  var shoe = require('shoe');
  var through = require('through');

  return function () {
    var stream = shoe('/racedata');
    stream.pipe(through(function (data) {
        console.log(JSON.parse(data));
    }));
  };
})();