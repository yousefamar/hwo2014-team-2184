require! \moment

log = console.log
clamp = (num, min, max) -> Math.max min, (Math.min max, num)
start-moment = null

knowledge =
  tick  : 0
  lap   : 0
  crashed : no
  turbo-available : no
  self  : {}
  track : null
  cars  : null
  max-laps : null

model =
  hold : (throttle, angle, curve) ->
    # returns whether a car with `throttle` at an `angle` on curve of `{ angle,
    # radius }` will stay on track (i.e. not crash).
    if (throttle > 0.8) or (Math.abs angle > 10 and throttle > 0.4)
      then false else true

calc-throttle = -> # use `knowledge` and channel zen

  { self, track : { pieces } } = knowledge
  piece-id = self.piece-position.piece-index

  potential-throttles = [ 0 to 1 by 0.1 ]

  # Try all possible controls, see what doesn't kill us
  potential-throttles.reduce (best-so-far, throttle) ->
    if model.hold throttle, self.angle, pieces[piece-id]
      throttle
    else best-so-far

# Conforms to [the specs](https://helloworldopen.com/techspec)

# TODO: Server can send multiple messages per game tick; only reply once.
handlers =
  join : (data) ->
    log "Joined"

  your-car : (data) ->
    knowledge.self <<< data
    log "We're #{data.name} and coloured #{data.color}!"

  game-init : (data) ->
    knowledge
      ..track     = data.race.track
      ..cars      = data.race.cars
      ..max-laps  = data.race.race-session.laps

  game-start : (data) ->
    start-moment := moment!
    log "Race started (#{start-moment.format!})"
    [\throttle, 1.0]

  car-positions : (data) ->
    knowledge.self = data.filter (.id.name is "kill -9") .0
    knowledge.positions = data.positions
    t = calc-throttle!
    console.log "THROTTLING AT #t"
    [ \throttle t ]

  crash : (data) ->
    knowledge.crashed = true
    log "#{data.name} crashed"

  spawn : (data) ->
    knowledge.crashed = false
    log "#{data.name} respawned"
    [\throttle, 1.0]

  lap-finished : (data) ->
    log "Finished lap #{knowledge.lap}"
    knowledge.lap++
    [\throttle, 1.0]

  dnf : (data) ->
    log "#{data.name DNF} because it #{data.reason}"
    [\throttle, 1.0]

  finish : (data) ->
    log "#{data.name} finished the race"
    [\throttle, 1.0]

  turbo-available : (data) ->
    # Burn it all straight away
    #log "#{knowledge.self.name}: #{knowledge.self.turbo-msg}"
    [\turbo, knowledge.self.turbo-msg]

  game-end : (data) ->
    end-moment = moment!
    duration = moment.duration (end-moment.diff start-moment)
    log "Race ended (#{end-moment.format!})"
    log "Duration: #{duration.humanize!}"

  tournament-end : (data) ->
    log "Tournament ended"

module.exports = -> handlers[it.msg-type]? it.data
