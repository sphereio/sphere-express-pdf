_ = require 'underscore'
pkg = require '../package.json'

module.exports = (app) ->

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    # - generate pdf
    # - respond with JSON containing link to PDF

  # generate and render pdf in the browser
  app.post '/api/pdf/render', (req, res, next) ->
    # - generate pdf
    # - respond with pdf

  # generate and download pdf
  app.post '/api/pdf/download', (req, res, next) ->
    # - generate pdf
    # - respond with download
