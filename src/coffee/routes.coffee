_ = require 'underscore'
fs = require 'fs'
path = require 'path'
phantom = require 'phantom'
pkg = require '../package.json'
Pdf = require './ws/pdf'

module.exports = (app, logger) ->

  _ph = null
  port = app.get 'port'
  baseUrl = "http://localhost:#{port}"

  filePath = (name) -> path.join(__dirname, '../tmp', name)

  createPdf = (payload, cb) ->
    pdf = new Pdf logger, payload
    pdf.generate _ph, (tmpFileName) ->
      if pdf._options.download
        renderOrDownload = 'download'
      else
        renderOrDownload = 'render'
      cb(tmpFileName, renderOrDownload)

  loadPdf = (fileName, res, cb) ->
    requestedPath = filePath(fileName)
    fs.readFile requestedPath, (err, data) ->
      if err
        logger.warn "File #{fileName} not found"
        res.send 404
      else
        cb(data)

  renderPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.type 'application/pdf'
      res.send data

  downloadPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.download filePath(fileName), fileName

  app.all '*', (req, res, next) ->
    # req.connection.setTimeout(2 * 60 * 1000) # two minute timeout
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', '*'
    res.header 'Access-Control-Allow-Methods', 'GET, POST'

    if _ph
      logger.info 'Phantom process already running, skipping...'
      next()
    else
      phantomOpts =
        port: (port - 1)
      phantom.create "--web-security=no", "--ignore-ssl-errors=yes",
        phantomOpts
      , (ph) ->
        _ph = ph
        logger.info "New phantom process created on port #{phantomOpts.port}"
        next()

  # homepage
  app.get '/', (req, res, next) ->
    res.json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    createPdf req.body, (tmpFileName, renderOrDownload) ->
      res.json
        status: 200
        expires_in: 60 * 30 # 30 min
        file: tmpFileName
        # TODO: define baseUrl pro environment
        url: "#{baseUrl}/api/pdf/#{renderOrDownload}/#{tmpFileName}"

  # render existing pdf in the browser
  app.get '/api/pdf/render/:fileName', (req, res, next) ->
    renderPdf(req.param('fileName'), res)

  # download existing pdf
  app.get '/api/pdf/download/:fileName', (req, res, next) ->
    downloadPdf(req.param('fileName'), res)

  # generate and render pdf in the browser
  app.post '/api/pdf/render', (req, res, next) ->
    createPdf req.body, (tmpFileName) ->
      renderPdf(tmpFileName, res)

  # generate and download pdf
  app.post '/api/pdf/download', (req, res, next) ->
    createPdf req.body, (tmpFileName) ->
      downloadPdf(tmpFileName, res)
