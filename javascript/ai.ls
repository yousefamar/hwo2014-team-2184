require! \moment

log = console.log
start-moment = null

own-car = turbo-msg : "TURBO NO JUTSU"

# Conforms to [the specs](https://helloworldopen.com/techspec)

handlers =
  join : (data) ->
    log "Joined"
  
  your-car : (data) ->
    own-car <<<< data
    log "#{data.name}'s colour is #{data.color}"

  game-init : (data) ->

  game-start : (data) ->
    start-moment := moment!
    log "Race started (#{start-moment.format!})"
    [\throttle, 1.0]

  car-positions : (data) ->
    [\throttle, 1.0]

  crash : (data) ->
    log "#{data.name} crashed"

  spawn : (data) ->
    log "#{data.name} respawned"
    [\throttle, 1.0]

  lap-finished : (data) ->
    log "Lap finished"
    [\throttle, 1.0]

  dnf : (data) ->
    log "#{data.name DNF} because it #{data.reason}"
    [\throttle, 1.0]

  finish : (data) ->
    log "#{data.name} finished the race"
    [\throttle, 1.0]

  turbo-available : (data) ->
    # Burn it all straight away
    log "#{own-car.name}: #{own-car.turbo-msg}"
    [\turbo, own-car.turbo-msg]

  game-end : (data) ->
    end-moment = moment!
    duration = moment.duration (end-moment.diff start-moment)
    log "Race ended (#{end-moment.format!})"
    log "Duration: #{duration.humanize!}"

  tournament-end : (data) ->
    log "Tournament ended"

module.exports = -> handlers[it.msg-type]? it.data