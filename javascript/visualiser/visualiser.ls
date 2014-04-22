window.VIS = {}

window.VIS.main = do

  shoe = require 'shoe'
  through = require 'through'

  divs = {}

  ->
    shoe '/racedata' .pipe through (data) ->
      console.dir data
      msg = JSON.parse data

      if msg.msgType of divs
        divs[msg.msgType].innerHTML = data;
      else
        document.createTextNode msg.msgType+': ' |> document.body.appendChild
        div = divs[msg.msgType] = document.createElement 'div'
        div.innerHTML = data;
        document.body.appendChild div
