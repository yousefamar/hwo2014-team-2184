require! \moment

log = console.log
clamp = (num, min, max) -> if num < min then min else if num > max then max else num
start-moment = null

game-tick = 0

pieces = null

own-car =
  turbo-msg : "TURBO NO JUTSU"
  is-crashed : false
  lookahead-dist: 10pcs
  calc-throttle: (piece-id) ->
    throttle = 0.0
    curve = 0.0
    weight-sum = 0.0
    for i from piece-id til piece-id+this.lookahead-dist by 1
      piece = pieces[i%pieces.length]
      weight = (0.8**i)/this.lookahead-dist
      # I can't maths
      weight-sum += weight
      throttle += if piece.radius? then weight * Math.abs(piece.angle/piece.radius) else weight * 1.0
    throttle /= weight-sum
    clamp throttle, 0.0, 1.0

# Conforms to [the specs](https://helloworldopen.com/techspec)

# TODO: Server can send multiple messages per game tick; only reply once.
handlers =
  join : (data) ->
    log "Joined"
  
  your-car : (data) ->
    own-car <<<< data
    log "#{data.name}'s colour is #{data.color}"

  game-init : (data) ->
    pieces := data.race.track.pieces
    log "#{pieces.length} pieces in the track"

  game-start : (data) ->
    start-moment := moment!
    log "Race started (#{start-moment.format!})"
    [\throttle, 1.0]

  car-positions : (data) ->
    for car in data
      if car.id.name is own-car.name and not own-car.is-crashed
        throttle = own-car.calc-throttle car.piece-position.piece-index
        log "Throttle at #throttle"
        return [\throttle, throttle]

  crash : (data) ->
    own-car.is-crashed := true
    log "#{data.name} crashed"

  spawn : (data) ->
    own-car.is-crashed := false
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
    #log "#{own-car.name}: #{own-car.turbo-msg}"
    #[\turbo, own-car.turbo-msg]

  game-end : (data) ->
    end-moment = moment!
    duration = moment.duration (end-moment.diff start-moment)
    log "Race ended (#{end-moment.format!})"
    log "Duration: #{duration.humanize!}"

  tournament-end : (data) ->
    log "Tournament ended"

module.exports = -> handlers[it.msg-type]? it.data