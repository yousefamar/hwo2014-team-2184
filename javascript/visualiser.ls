http = require \http
open = require \open
shoe = require \shoe
ecstatic = (require \ecstatic) \visualiser

last-stream = null

module.exports =

  init : (port=8000) ->
    server = http.create-server ecstatic
    server.listen port

    sock = shoe (stream) ->
      last-stream := stream

      stream.on \end ->
      #stream.pipe(process.stdout, { end : false });
    sock.install server, \/racedata

    open "http://localhost:#port/index.html"

  update : (data) ->
    last-stream && last-stream.write JSON.stringify data
