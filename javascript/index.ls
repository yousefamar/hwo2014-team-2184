require! \net
JSON-stream = require \JSONStream
require! \moment
update-vis = (require \./visualiser.ls)!

log = console.log

[ _, _, server-host, server-port, name, key ] = process.argv

log "#name connecting to #server-host:#server-port"

client = net.connect server-port, server-host, ->
  send \join { name, key }

send = (msg-type=\ping, data={}) ->
  client.write JSON.stringify { msg-type, data }
  client.write "\n"

start-moment = null
client.pipe JSON-stream.parse!
  ..on \data (data) ->

    update-vis data

    if data.msg-type is \carPositions
      send \throttle 0.5
    else
      switch data.msg-type
      | \join => log "Joined"
      | \gameStart =>
        start-moment := moment!
        log "Race started (#{start-moment.format!})"
      | \gameEnd =>
        end-moment = moment!
        duration = moment.duration (end-moment.diff start-moment)
        log "Race ended (#{end-moment.format!})"
        log "Duration: #{duration.humanize!}"

      send \ping

  ..on \error -> console.log "disconnected"

# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2
