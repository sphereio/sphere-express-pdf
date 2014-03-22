EventEmitter = require('events').EventEmitter
domain = require 'domain'
express = require 'express'
Logger = require './logger'

ee = new EventEmitter()
app = express()
env = app.get 'env'

{port, logStream} = switch env
  when 'production'
    port: 8888
    logStream: [
      {level: 'info', path: './sphere-express-pdf.log'}
    ]
  else
    port: 3999
    logStream: [
      {level: 'info', stream: process.stdout}
    ]

logger = new Logger
  name: 'sphere-express-pdf'
  streams: logStream

logger.info "Starting express application on port #{port} (#{env})"

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
  app.use (req, res, next) ->
    requestDomain = domain.create()
    requestDomain.add(req)
    requestDomain.add(res)
    requestDomain.on 'error', next
    requestDomain.run(next)
  app.use require('./middleware/logger')(logger)
  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()
  app.use express.cookieParser('o4i6XvJXjHF1eQfTpE1E')
  app.use express.session()
  app.use app.router
  app.use express.compress()
  app.use (err, req, res, next) ->
    logger.error err
    res.send 500,
      message: 'Oops, something went wrong!'

require('./routes')(app, port, ee)

# only start the server if the file is run directly, not when it is required
if __filename is process.argv[1]
  server = app.listen port
  logger.info "Listening for HTTP on http://localhost:#{port}"

ee.on 'tearDown', (ph) ->
  logger.info 'Cleaning phantom process.'
  ph?.exit()
  logger.info 'Attempting gracefully shutdown of server.'
  server?.close()
  process.exit()

module.exports = app
