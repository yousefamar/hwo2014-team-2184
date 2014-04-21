require! <[ http open shoe ]>
ecstatic = (require \ecstatic) \visualiser

init = (port=8000) ->

  last-stream = null

  server = http.create-server ecstatic
    ..listen port

  sock = shoe -> last-stream := it
  sock.install server, \/racedata

  open "http://localhost:#port/index.html"

  # Return update function
  (data) -> last-stream?write JSON.stringify data

module.exports = init
