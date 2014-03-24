_ = require 'underscore'
fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
Handlebars = require 'handlebars'

FORMATS = ['A3', 'A4', 'A5', 'Legal', 'Letter', 'Tabloid']
ORIENTATIONS = ['portrait', 'landscape']
MARGIN_REGEX = /^\d+(in|cm|mm)$/

require('../utils/handlebarsHelpers')(Handlebars)

class Pdf

  constructor: (@logger, options = {}) ->
    # TODO: validate paper size options
    @_options = _.defaults options,
      paperSize:
        format: 'A4'
        orientation: 'portrait'
        border: '1cm'
      # header: ''
      # footer: ''
      content: ''
      context: {}
      download: false

  generate: (ph, cb) ->
    @_page = null
    try
      timestamp = new Date().getTime() # ensure it's unique
      randomToken = crypto.randomBytes(32).toString('hex')
      tmpFileName = "#{timestamp}-#{randomToken}.pdf"
      tmpFilePath = path.join(__dirname, '../../tmp', tmpFileName)

      # compile
      html = Handlebars.compile(@_options.content)(@_options.context)

      ph.createPage (page) =>
        @_page = page
        page.set 'paperSize', @_options.paperSize
        page.setContent html, '', (status) =>
          @logger.debug "Content set to page with status: #{status}"
          page.render tmpFilePath, =>
            page.close()
            @logger.info "New PDF generated: #{tmpFileName}"
            cb(tmpFileName)
    catch e
      @_page?.close()
      throw new Error e

module.exports = Pdf
