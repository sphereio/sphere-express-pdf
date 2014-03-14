_ = require 'underscore'
pkg = require '../package.json'
Pdf = require './ws/pdf'

module.exports = (app, port) ->

  baseUrl = "http://localhost:#{port}"

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    req.connection.setTimeout(2 * 60 * 1000) # two minute timeout
    # - generate pdf
    # - respond with JSON containing link to PDF

    # options from request body
    console.log req.body
    pdf = new Pdf req.body
    pdf.generate (tmpFileName) ->
      res.json
        status: 200
        expires_in: '???'
        # TODO: check whether it should render or download
        # TODO: define baseUrl pro environment
        url: "#{baseUrl}/api/pdf/render/#{tmpFileName}"

  # generate and render pdf in the browser
  app.get '/api/pdf/render/:token', (req, res, next) ->
    res.send 501,
      message: 'Endpoint not implemented yet'

  # generate and render pdf in the browser
  app.post '/api/pdf/render', (req, res, next) ->
    res.send 401,
      message: 'Not authorized'
    # - generate pdf
    # - respond with pdf

  # generate and render pdf in the browser
  app.get '/api/pdf/download/:token', (req, res, next) ->
    res.send 501,
      message: 'Endpoint not implemented yet'

  # generate and download pdf
  app.post '/api/pdf/download', (req, res, next) ->
    res.send 401,
      message: 'Not authorized'
    # - generate pdf
    # - respond with download
