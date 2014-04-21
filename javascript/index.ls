net = require \net
JSON-stream = require \JSONStream
moment = require \moment
visualiser = require \./visualiser.js

server-host = process.argv.2
server-port = process.argv.3
bot-name = process.argv.4
bot-key= process.argv.5

console.log "I'm #bot-name and connect to #server-host:#server-port"

client = net.connect server-port, server-host, ->

  visualiser.init!

  send do
    msg-type : \join
    data :
      name : bot-name
      key  : bot-key

send = (json) ->
  client.write JSON.stringify json
  client.write "\n"

stream = client.pipe JSON-stream.parse!

start-moment = null

stream.on \data (data) ->

  visualiser.update data

  if data.msg-type is \carPositions
    send do
      msg-type : \throttle
      data : 0.5
  else
    if data.msg-type is \join
      console.log "Joined"
    else if data.msg-type is \gameStart
      start-moment = moment!
      console.log "Race started (#{start-moment.format!})"
    else if data.msg-type is \gameEnd
      end-moment = moment!
      duration = moment.duration (end-moment.diff start-moment)
      console.log "Race ended (#{end-moment.format!})"
      console.log "Duration: #{duration.humanize!}"

    send do
      msg-type : \ping
      data : {}

stream.on \error -> console.log "disconnected"

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
