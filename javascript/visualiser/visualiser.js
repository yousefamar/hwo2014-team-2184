VIS = {};

VIS.main = (function () {
  var shoe = require('shoe');
  var through = require('through');

  var divs = {};

  return function () {
    var stream = shoe('/racedata');
    stream.pipe(through(function (data) {
      var msg = JSON.parse(data);

      if (msg.msgType in divs) {
        divs[msg.msgType].innerHTML = data;
      } else {
        document.body.appendChild(document.createTextNode(msg.msgType+': '));
        var div = divs[msg.msgType] = document.createElement('div');
        div.innerHTML = data;
        document.body.appendChild(div);
      }
    }));
  };
})();