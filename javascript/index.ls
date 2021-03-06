require! \net
JSON-stream = require \JSONStream
racelog = (require \./racelog.ls)!
actuate = require \./ai.ls

log = console.log

[ _, _, server-host, server-port, name, key ] = process.argv

log "#name connecting to #server-host:#server-port"

client = net.connect server-port, server-host, ->
  send [ \join { name, key } ]

send = (payload) ->
  default-payload = [ \ping {} ]
  [ msg-type, data ] = default-payload <<< payload
  client.write JSON.stringify { msg-type, data }
  client.write "\n"

client
  ..pipe racelog
  ..pipe JSON-stream.parse!
    ..on \data -> actuate it |> send
    ..on \error -> console.log "disconnected"

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
