#!/usr/bin/env node_modules/LiveScript/bin/lsc

# Expects newline-delimited JSON on stdin. Starts a browser and pipes the JSON
# (split on newlines) to it through a WebSocket.

require! <[ fs http open shoe split ]>
ecstatic = (require \ecstatic) \visualiser

port = 8000

server = http.create-server ecstatic
  ..listen port

sock = shoe (stream) ->
  process.stdin .pipe split! .pipe stream
sock.install server, \/racedata

open "http://localhost:#port/index.html"
