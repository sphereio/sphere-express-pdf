_ = require 'underscore'
pkg = require '../package.json'

module.exports = (app) ->

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # generate and render pdf in the browser
  app.get '/api/pdf/:token', (req, res, next) ->
    res.send 501,
      message: 'Endpoint not implemented yet'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    # - generate pdf
    # - respond with JSON containing link to PDF

  # generate and render pdf in the browser
  app.post '/api/pdf/render', (req, res, next) ->
    res.send 401,
      message: 'Not authorized'
    # - generate pdf
    # - respond with pdf

  # generate and download pdf
  app.post '/api/pdf/download', (req, res, next) ->
    res.send 401,
      message: 'Not authorized'
    # - generate pdf
    # - respond with download
