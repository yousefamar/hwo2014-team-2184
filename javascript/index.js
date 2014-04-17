var net = require("net");
var JSONStream = require('JSONStream');
var moment = require("moment");
var visualiser = require('./visualiser.js');

var serverHost = process.argv[2];
var serverPort = process.argv[3];
var botName = process.argv[4];
var botKey = process.argv[5];

console.log("I'm", botName, "and connect to", serverHost + ":" + serverPort);

client = net.connect(serverPort, serverHost, function() {

  visualiser.init();

  return send({
    msgType: "join",
    data: {
      name: botName,
      key: botKey
    }
  });
});

function send(json) {
  client.write(JSON.stringify(json));
  return client.write('\n');
};

jsonStream = client.pipe(JSONStream.parse());

var startMoment = null;

jsonStream.on('data', function(data) {

  visualiser.update(data);

  if (data.msgType === 'carPositions') {
    send({
      msgType: "throttle",
      data: 0.5
    });
  } else {
    if (data.msgType === 'join') {
      console.log('Joined')
    } else if (data.msgType === 'gameStart') {
      startMoment = moment();
      console.log('Race started (' + startMoment.format() + ')');
    } else if (data.msgType === 'gameEnd') {
      var endMoment = moment();
      var duration = moment.duration(endMoment.diff(startMoment));
      console.log('Race ended (' + endMoment.format() + ')');
      console.log('Duration: ' + duration.humanize());
    } 

    send({
      msgType: "ping",
      data: {}
    });
  }
});

jsonStream.on('error', function() {
  return console.log("disconnected");
});
// vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
