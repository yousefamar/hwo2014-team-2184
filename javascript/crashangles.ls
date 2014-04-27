#!/usr/bin/env node_modules/LiveScript/bin/lsc

data = require './logs/crashy.json'
angle = 0.0
for msg in data
	switch msg.msg-type
	| \fullCarPositions => angle := msg.data[0].angle
	| \crash => console.log "Crash after angle at #angle"