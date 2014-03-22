_ = require 'underscore'
bunyan = require 'bunyan'

module.exports = class

  constructor: (config = {}) ->
    return bunyan.createLogger _.defaults config,
      name: 'sphere-express-pdf'
      serializers: bunyan.stdSerializers
      streams: [
        {level: 'info', stream: process.stdout}
      ]
