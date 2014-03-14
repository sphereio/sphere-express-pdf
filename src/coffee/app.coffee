express = require 'express'
path = require 'path'

# middleware = require './middleware'

port = switch process.env.NODE_ENV
  when 'production' then 8888
  else 3000
app = express()

###*
 * Configure express application
 * - domain: allows to group operations and capture all errors in that contex (http://nodejs.org/api/domain.html)
 * - logger: logs every request
 * - router: setup routes
 * - compress: compress response data with gzip / deflate
 * - error handlers
 * @return {[type]} [description]
###
app.configure ->
  # app.use middleware.domain() # we can enable this later
  app.use express.logger()
  app.use app.router
  app.use express.compress()
  app.use (err, req, res, next) ->
    # TODO: use logger
    console.error err.stack
    # TODO: use JSON response
    res.send 500, 'Something broke!'

require('./routes')(app, port)

app.listen port
console.log "Listening on http://localhost:#{port}/"
