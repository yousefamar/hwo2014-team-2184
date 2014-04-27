require! \moment

log = console.log
clamp = (num, min, max) -> if num < min then min else if num > max then max else num
start-moment = null

game-tick = 0

own-car =
  turbo-msg : "TURBO NO JUTSU"
  is-crashed : false
  pid :
    angle-target : 45.0
    pid-constants :
      kp : 0.019
      ki : 0.01
      kd : 0.5
    _prev-error : 0.0
    _sum-error : 0.0
    calc-throttle : (angle) ->
      error = this.angle-target - Math.abs(angle)
      this._sum-error += error
      this._sum-error := 0.01 * clamp this._sum-error, 0.0, this.angle-target
      d-error = error - this._prev-error
      this._prev-error = error
      throttle = clamp (this.pid-constants.kp * error + this.pid-constants.ki * this._sum-error + this.pid-constants.kd * d-error), 0.0, 1.0
      log "Throttle at #throttle"
      throttle

# Conforms to [the specs](https://helloworldopen.com/techspec)

# TODO: Server can send multiple messages per game tick; only reply once.
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
    for car in data
      if car.id.name is own-car.name and not own-car.is-crashed
        return [\throttle, own-car.pid.calc-throttle car.angle]

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