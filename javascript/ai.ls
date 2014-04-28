require! \moment

log = console.log
clamp = (num, min, max) -> Math.max min, (Math.min max, num)
start-moment = null

knowledge =
  tick  : 0
  lap   : 0
  crashed : no
  self  : {}
  track : null
  cars  : null
  max-laps : null

calc-throttle = -> # use `knowledge` and channel zen

  lookahead-dist = 10

  { self, track : { pieces } } = knowledge
  piece-id = self.piece-position.piece-index

  throttle = curve = weight-sum = 0
  for i from piece-id til piece-id + lookahead-dist
    piece = pieces[i % pieces.length]
    weight = (0.8 ** i) / lookahead-dist
    # I can't maths
    weight-sum += weight
    throttle   += weight * switch piece.straight
                           | yes   => 1
                           | no  => Math.abs(piece.angle/piece.radius)
  throttle /= weight-sum
  clamp throttle, 0 1

# Conforms to [the specs](https://helloworldopen.com/techspec)

# TODO: Server can send multiple messages per game tick; only reply once.
handlers =
  join : (data) ->
    log "Joined"

  your-car : (data) ->
    knowledge.self <<< data
    log "We're #{data.name} and coloured #{data.color}!"

  game-init : (data) !->
    knowledge
      ..track     = data.race.track
      ..cars      = data.race.cars
      ..max-laps  = data.race.race-session.laps

    prev-piece = {distance: 0.0, length: 0.0}
    for piece in knowledge.track.pieces
      piece.straight = not piece.radius?
      if not piece.straight
        piece.length = 2 * Math.PI * piece.radius * piece.angle/360
      piece.distance = prev-piece.distance + prev-piece.length
      prev-piece = piece

    knowledge.track.length = prev-piece.distance + prev-piece.length

  game-start : (data) ->
    start-moment := moment!
    log "Race started (#{start-moment.format!})"
    [\throttle, 1.0]

  car-positions : (data) ->
    knowledge.self = data.filter (.id.name is "kill -9") .0
    knowledge.positions = data.positions
    t = calc-throttle!
    #console.log "THROTTLING AT #t"
    angle = knowledge.self.angle

    current-piece = knowledge.track.pieces[knowledge.self.piece-position.piece-index]
    knowledge.self.dist-traveled = knowledge.self.piece-position.lap * knowledge.track.length + current-piece.distance + knowledge.self.piece-position.in-piece-distance
    log "#{knowledge.self.angle},#{knowledge.self.dist-traveled}"
    [ \throttle 0.6 ]

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
    #[\turbo, knowledge.self.turbo-msg]

  game-end : (data) ->
    end-moment = moment!
    duration = moment.duration (end-moment.diff start-moment)
    log "Race ended (#{end-moment.format!})"
    log "Duration: #{duration.humanize!}"

  tournament-end : (data) ->
    log "Tournament ended"

module.exports = -> handlers[it.msg-type]? it.data
