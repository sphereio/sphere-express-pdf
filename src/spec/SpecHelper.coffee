_ = require 'underscore'
request = require 'request'

class Requester

  options: (path, method) ->
    uri: "http://localhost:3999#{path}"
    json: true
    method: method

  get: (path, callback) ->
    request @options(path, 'GET'), callback

  post: (path, body, callback) ->
    request _.extend({}, @options(path, 'POST'), {body: body}), callback

###
Mock express server
###
exports.withServer = (callback) ->
  asyncSpecWait()

  stopServer = ->
    asyncSpecDone()

  callback new Requester, stopServer
