require! \moment

log = console.log
start-moment = null

handlers = {}

# As conforming to specs at https://helloworldopen.com/techspec

handlers.car-positions = (data) ->
  [\throttle, 0.5]

handlers.join = (data) ->
  log "Joined"

handlers.game-start = (data) ->
  start-moment := moment!
  log "Race started (#{start-moment.format!})"
  [\throttle, 0.5]

handlers.game-end = (data) ->
  end-moment = moment!
  duration = moment.duration (end-moment.diff start-moment)
  log "Race ended (#{end-moment.format!})"
  log "Duration: #{duration.humanize!}"


actuate = (data) -> (data?msg-type? && handlers[data.msg-type]? data) || [\ping]

module.exports = actuate