path = require 'path'
domain = require 'domain'
express = require 'express'
Logger = require './logger'
pkg = require '../package.json'

APP_DIR = path.join(__dirname, '../')

server = null
gracefullyExiting = false

app = express()
env = app.get 'env'
{port, baseUrl, logStream} = switch env
  when 'production'
    port: 8888
    baseUrl: 'https://pdf.sphere.io'
    logStream: [
      if process.env.APP_ENV is 'docker'
      then {level: 'info', stream: process.stdout}
      else {level: 'info', path: "/var/log/#{pkg.name}/log"}
    ]
  else
    port: 3999
    baseUrl: 'http://localhost:3999'
    logStream: [
      {level: 'info', stream: process.stdout}
    ]
logger = new Logger
  name: pkg.name
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
app.set 'port', port
app.set 'baseUrl', baseUrl
app.set 'trust proxy', true
app.use (req, res, next) ->
  requestDomain = domain.create()
  requestDomain.add(req)
  requestDomain.add(res)
  requestDomain.on 'error', next
  requestDomain.run(next)
app.use (req, res, next) -> # enable CORS
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS'
  res.header 'Access-Control-Allow-Headers', 'Accept, Content-Type, Origin'
  if req.method is 'OPTIONS'
    res.status(200).send()
  else
    next()
app.use (req, res, next) ->
  return next() unless gracefullyExiting
  res.setHeader 'Connection', 'close'
  res.status(502).send message: 'Server is in the process of restarting.'
app.use (req, res, next) ->
  if req.url is '/robots.txt'
    res.redirect '/static/robots.txt'
  else
    next()
app.use require('./middleware/logger')(logger)
app.use '/static', express.static("#{APP_DIR}/public")
# see list of middlewares for express 4.x
# https://github.com/senchalabs/connect#middleware
# app.use require('serve-favicon')("#{APP_DIR}/public/images/favicon.ico")
app.use require('body-parser').json()
app.use require('cookie-parser')()
app.use require('cookie-session')({secret: 'o4i6XvJXjHF1eQfTpE1E'}) # TODO: don't expose it
app.use require('compression')()
app.use (err, req, res, next) ->
  logger.error err
  res.status(500).send message: 'Oops, something went wrong!'

require('./routes')(app, logger)

# starts server
server = app.listen port
logger.info "Listening for HTTP on http://localhost:#{port}"

module.exports = app
