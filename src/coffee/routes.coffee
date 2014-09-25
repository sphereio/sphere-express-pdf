_ = require 'underscore'
fs = require 'fs'
path = require 'path'
phantom = require 'phantom'
pkg = require '../package.json'
Pdf = require './ws/pdf'

module.exports = (app, logger) ->

  _ph = null
  _phIsStarting = false
  port = app.get 'port'

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
        res.status(404).send "File #{fileName} not found"
      else
        cb(data)

  renderPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.type 'application/pdf'
      res.status(200).send data

  downloadPdf = (fileName, res) ->
    loadPdf fileName, res, (data) ->
      res.status(200).download filePath(fileName), fileName



  app.all '*', (req, res, next) ->
    if _ph
      logger.debug 'Phantom process already running, skipping...'
      next()
    else unless _phIsStarting
      createPhantomProcess = ->
        _phIsStarting = true
        phantomOpts =
          port: (port - 1)
          onExit: ->
            logger.error 'Phantom process exited unexpectedly or crashed. Will try to spawn up a new process...'
            createPhantomProcess()
        phantom.create "--web-security=no", "--ignore-ssl-errors=yes",
          phantomOpts
        , (ph) ->
          _ph = ph
          _phIsStarting = false
          logger.info "New phantom process created on port #{phantomOpts.port}"
          next()
      createPhantomProcess()

  # homepage
  app.get '/', (req, res, next) ->
    res.status(200).json _.omit pkg, 'devDependencies'

  # retrieve a link to the generated pdf
  app.post '/api/pdf/url', (req, res, next) ->
    createPdf req.body, (tmpFileName, renderOrDownload) ->
      res.status(200).json
        status: 200
        expires_in: 60 * 30 # 30 min
        file: tmpFileName
        url: "#{app.get('baseUrl')}/api/pdf/#{renderOrDownload}/#{tmpFileName}"

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
