require! <[ d3 shoe through ]>

knowledge = {}

update-stat-text = ->
  s = d3.select \div#stats
  s.select \#game-state        .text (knowledge.game-state or "unknown")
  s.select \#n-cars            .text (knowledge.cars?length or 0)
  s.select \#track-id          .text (knowledge.track?id or "unknown track")
  s.select \#track-n-pieces    .text (knowledge.track?pieces.length or 0)
  s.select \#track-n-curves    .text (knowledge.track?pieces.filter (.radius) .length or 0)
  s.select \#track-n-straights .text (knowledge.track?pieces.filter (.length) .length or 0)
  s.select \#max-laps          .text (knowledge.max-laps or 0)

vis = d3.select \body .append \svg .attr \id \vis
track = vis.append \g .attr \class \track

derive-knowledge = (message) ->
  r = {}
  switch message.msg-type
  | \join     => r.game-state = "waiting to start"
  | \gameInit => r.game-state = "running"
  | \gameEnd  => r.game-state = "over"
  if message.msg-type is \gameInit
    r.track = message.data.race.track
    r.cars = message.data.race.cars
    r.max-laps = message.data.race.race-session.laps
  if message.msg-type in <[ gameStart carPositions ]>
    r.last-tick = message.data.game-tick

  r

shoe '/racedata' .pipe through (message) ->
  message = JSON.parse message
  knowledge <<< derive-knowledge message
  update-stat-text!
