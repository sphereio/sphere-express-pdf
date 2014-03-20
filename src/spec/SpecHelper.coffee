http = require 'http'

class Requester

  options: (path) ->
    host: 'localhost'
    port: '3999'
    path: path
    headers:
      'Content-Type': 'application/json'

  get: (path, callback) ->
    http.get @options(path), callback

  post: (path, body, callback) ->
    req = http.request @options(path), callback
    req.write body
    req.end()

###
Mock express server
###
exports.withServer = (callback) ->
  asyncSpecWait()

  stopServer = ->
    asyncSpecDone()

  callback new Requester, stopServer
