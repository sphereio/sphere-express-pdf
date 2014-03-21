Q = require 'q'
_ = require 'underscore'
request = require 'request'

class Requester

  options: (path, method) ->
    uri: "http://localhost:3999#{path}"
    json: true
    method: method

  get: (path, callback) ->
    d = Q.defer()
    request @options(path, 'GET'), (e, r, b) ->
      if e
        console.error e
        d.reject e
      else
        d.resolve
          response: r
          body: b
    d.promise

  post: (path, body, callback) ->
    d = Q.defer()
    request _.extend({}, @options(path, 'POST'), {body: body}), (e, r, b) ->
      if e
        console.error e
        d.reject e
      else
        d.resolve
          response: r
          body: b
    d.promise


module.exports =
  http: new Requester
