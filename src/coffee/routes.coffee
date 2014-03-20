_ = require 'underscore'
phantom = require 'phantom'
pkg = require '../package.json'
Pdf = require './ws/pdf'

module.exports = (app, port) ->

  baseUrl = "http://localhost:#{port}"

  process.on 'exit', (a, b) =>
    console.log 'Cleaning phantom process'
    @_ph?.exit()
    process.exit()

  app.all '*', (req, res, next) ->
    # req.connection.setTimeout(2 * 60 * 1000) # two minute timeout
    if @_ph
      console.log 'Phantom process already running, skipping...'
      next()
    else
      phantom.create "--web-security=no", "--ignore-ssl-errors=yes", {}, (ph) =>
        @_ph = ph
        console.log 'New phantom process created'
        next()

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    # - generate pdf
    # - respond with JSON containing link to PDF

    # options from request body
    pdf = new Pdf req.body
    pdf.generate @_ph, (tmpFileName) ->
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
