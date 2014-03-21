_ = require 'underscore'
fs = require 'fs'
path = require 'path'
phantom = require 'phantom'
pkg = require '../package.json'
Pdf = require './ws/pdf'

module.exports = (app, port) ->

  baseUrl = "http://localhost:#{port}"

  filePath = (name) -> path.join(__dirname, '../tmp', name)

  notFound = (err, res) ->
    console.log "File not found: #{err}"
    res.send 404,
      message: 'File not found'

  createPdf = (payload, cb) ->
    pdf = new Pdf payload
    pdf.generate @_ph, (tmpFileName) ->
      if pdf._options.download
        renderOrDownload = 'download'
      else
        renderOrDownload = 'render'
      cb(tmpFileName, renderOrDownload)

  loadPdf = (fileName, res, cb) ->
    requestedPath = filePath(fileName)
    fs.readFile requestedPath, (err, data) ->
      if err
        notFound(err, res)
      else
        cb(data)

  renderPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.type 'application/pdf'
      res.send data

  downloadPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.download filePath(fileName), fileName

  process.on 'exit', (a, b) =>
    console.log 'Cleaning phantom process'
    @_ph?.exit()
    process.exit()

  process.on 'uncaughtException', (err) ->
    console.error err.stack
    # TODO: should not exit and block thread
    process.exit(1)

  app.all '*', (req, res, next) ->
    # req.connection.setTimeout(2 * 60 * 1000) # two minute timeout
    if @_ph
      console.log 'Phantom process already running, skipping...'
      next()
    else
      phantomOpts =
        port: (port - 1)
      phantom.create "--web-security=no", "--ignore-ssl-errors=yes",
        phantomOpts
      , (ph) =>
        @_ph = ph
        console.log "New phantom process created on port #{phantomOpts.port}"
        next()

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    createPdf req.body, (tmpFileName, renderOrDownload) ->
      res.json
        status: 200
        expires_in: '???'
        file: tmpFileName
        # TODO: define baseUrl pro environment
        url: "#{baseUrl}/api/pdf/#{renderOrDownload}/#{tmpFileName}"

  # render existing pdf in the browser
  app.get '/api/pdf/render/:token', (req, res, next) ->
    renderPdf(req.param('token'), res)

  # download existing pdf
  app.get '/api/pdf/download/:token', (req, res, next) ->
    downloadPdf(req.param('token'), res)

  # generate and render pdf in the browser
  app.post '/api/pdf/render', (req, res, next) ->
    createPdf req.body, (tmpFileName) ->
      renderPdf(tmpFileName, res)

  # generate and download pdf
  app.post '/api/pdf/download', (req, res, next) ->
    createPdf req.body, (tmpFileName) ->
      downloadPdf(tmpFileName, res)
