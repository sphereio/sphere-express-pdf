bunyan = require 'bunyan'

# TODO: init logger with custom config
module.exports = class

  constructor: (config = {}) ->
    return bunyan.createLogger
      name: 'sphere-express-pdf'
      serializers: bunyan.stdSerializers
      streams: [
        {level: 'info', stream: process.stdout}
        {level: 'error', stream: process.stderr}
        {level: 'debug', path: './sphere-express-pdf-debug.log'}
      ]
