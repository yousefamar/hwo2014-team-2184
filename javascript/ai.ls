require! \moment

log = console.log
start-moment = null

# Conforms to [the specs](https://helloworldopen.com/techspec)

handlers =
  car-positions : (data) ->
    [\throttle, 0.6]

  join : (data) ->
    log "Joined"

  game-start : (data) ->
    start-moment := moment!
    log "Race started (#{start-moment.format!})"
    [\throttle, 0.6]

  game-end : (data) ->
    end-moment = moment!
    duration = moment.duration (end-moment.diff start-moment)
    log "Race ended (#{end-moment.format!})"
    log "Duration: #{duration.humanize!}"

module.exports = actuate = -> handlers[it.msg-type]? it
