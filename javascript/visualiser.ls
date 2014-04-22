#!node_modules/LiveScript/bin/lsc
require! <[ fs http open shoe split ]>
ecstatic = (require \ecstatic) \visualiser

port = 8000

server = http.create-server ecstatic
  ..listen port

sock = shoe (stream) ->
  process.stdin .pipe split! .pipe stream
sock.install server, \/racedata

open "http://localhost:#port/index.html"
