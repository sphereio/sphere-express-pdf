EventEmitter = require('events').EventEmitter
domain = require 'domain'
express = require 'express'

ee = new EventEmitter()
app = express()

env = app.get 'env'
console.log "Node environment: #{env}"

port = switch env
  when 'production' then 8888
  else 3999

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
  app.use express.logger()
  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()
  app.use express.cookieParser('o4i6XvJXjHF1eQfTpE1E')
  app.use express.session()
  app.use app.router
  app.use express.compress()
  app.use (err, req, res, next) ->
    # TODO: use logger
    console.log 'Caught exception'
    console.error err.stack
    # TODO: use JSON response
    res.send 500,
      message: 'Oops, something went wrong!'

require('./routes')(app, port, ee)

# only start the server if the file is run directly, not when it is required
if __filename is process.argv[1]
  server = app.listen port
  console.log "Listening on http://localhost:#{port}/"

ee.on 'tearDown', (ph) ->
  console.log 'Cleaning phantom process...'
  ph?.exit()
  console.log 'Attempting gracefully shutdown of server...'
  server?.close()
  process.exit()

module.exports = app
