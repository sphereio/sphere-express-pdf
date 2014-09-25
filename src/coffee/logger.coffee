_ = require 'underscore'
bunyan = require 'bunyan'
pkg = require '../package.json'

module.exports = class

  constructor: (config = {}) ->
    return bunyan.createLogger _.defaults config,
      name: pkg.name
      serializers: bunyan.stdSerializers
      streams: [
        {level: 'info', stream: process.stdout}
      ]
