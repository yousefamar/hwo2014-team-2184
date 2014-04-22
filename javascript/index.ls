require! \net
JSON-stream = require \JSONStream
racelog = (require \./racelog.ls)!
actuate = require \./ai.ls

log = console.log

[ _, _, server-host, server-port, name, key ] = process.argv

log "#name connecting to #server-host:#server-port"

client = net.connect server-port, server-host, ->
  send \join { name, key }

send = (msg-type=\ping, data={}) ->
  client.write JSON.stringify { msg-type, data }
  client.write "\n"

start-moment = null
client
  ..pipe racelog
  ..pipe JSON-stream.parse!
    ..on \data (data) -> actuate data |> send.apply null, _

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
