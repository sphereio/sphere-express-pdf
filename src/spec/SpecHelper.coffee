http = require 'http'

class Requester

  options: (path) ->
    host: 'localhost'
    port: '3999'
    path: path
    headers:
      'Content-Type': 'application/json'

  get: (path, callback) ->
    http.get @options(path), (res) => @_handleResponse res, callback

  post: (path, body, callback) ->
    req = http.request @options(path), (res) => @_handleResponse res, callback
    req.write body
    req.end()

  _handleResponse: (res, cb) ->
    expect(res.statusCode).toBe 200
    expect(res.headers['content-type']).toBe 'application/json; charset=utf-8'
    res.setEncoding('utf-8')
    res.on 'data', (chunk) ->
      data = JSON.parse chunk
      cb(data)

###
Mock express server
###
exports.withServer = (callback) ->
  asyncSpecWait()

  stopServer = ->
    asyncSpecDone()

  callback new Requester, stopServer
