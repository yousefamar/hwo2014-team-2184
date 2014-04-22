require! <[ fs moment mkdirp ]>
log-dir = "logs"

module.exports = new-racelog = ->
  mkdirp.sync log-dir # create unless exists
  fs.create-write-stream "#log-dir/#{moment!format "YYYY_MM_DD_hh:mm:ss"}.nl-json"
