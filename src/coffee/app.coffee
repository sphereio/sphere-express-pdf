require('strong-agent').profile()
domain = require 'domain'
express = require 'express'
Logger = require './logger'

server = null
gracefullyExiting = false

app = express()
env = app.get 'env'
{port, baseUrl, logStream} = switch env
  when 'production'
    port: 8888
    baseUrl: 'https://pdf.sphere.io'
    logStream: [
      {level: 'info', path: '/var/log/sphere-express-pdf/log'}
    ]
  else
    port: 3999
    baseUrl: 'http://localhost:3999'
    logStream: [
      {level: 'info', stream: process.stdout}
    ]
logger = new Logger
  name: 'sphere-express-pdf'
  streams: logStream

logger.info "Starting express application on port #{port} (#{env})"

handleTearDown = ->
  gracefullyExiting = true
  logger.info 'Attempting gracefully shutdown of server, waiting for remaining connections to complete.'

  # TODO: those callbacks will actually not be called since the SIGINT listener from phantom will exit the process before we get here
  server.close ->
    logger.info 'No more connections, shutting down server.'
    process.exit()
  setTimeout ->
    logger.error 'Could not close connections in time, forcefully shutting down.'
    process.exit(1)
  , 30 * 1000 # 30s

process.on 'SIGINT', handleTearDown
process.on 'SIGTERM', handleTearDown

###*
 * Configure express application
 * - domain: allows to group operations and capture all errors in that contex (http://nodejs.org/api/domain.html)
 * - logger: logs every request
 * - router: setup routes
 * - compress: compress response data with gzip / deflate
 * - error handlers
###
app.configure ->
  app.set 'port', port
  app.set 'baseUrl', baseUrl
  app.enable 'trust proxy'
  app.use (req, res, next) ->
    requestDomain = domain.create()
    requestDomain.add(req)
    requestDomain.add(res)
    requestDomain.on 'error', next
    requestDomain.run(next)
  app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS'
    res.header 'Access-Control-Allow-Headers', 'Accept, Content-Type, Origin'
    if req.method is 'OPTIONS'
      res.send 200
    else
      next()
  app.use (req, res, next) ->
    return next() unless gracefullyExiting
    res.setHeader 'Connection', 'close'
    res.send 502, message: 'Server is in the process of restarting.'
  app.use require('./middleware/logger')(logger)
  app.use '/', express.static("#{__dirname}/../public")
  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()
  app.use express.cookieParser('o4i6XvJXjHF1eQfTpE1E')
  app.use express.cookieSession()
  app.use app.router
  app.use express.compress()
  app.use (err, req, res, next) ->
    logger.error err
    res.send 500, message: 'Oops, something went wrong!'

require('./routes')(app, logger)

# only start the server if the file is run directly, not when it is required
if __filename is process.argv[1]
  server = app.listen port
  logger.info "Listening for HTTP on http://localhost:#{port}"
else
  logger.debug "Module is being required, skipping server start..."

module.exports = app
