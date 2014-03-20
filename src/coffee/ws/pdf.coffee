_ = require 'underscore'
fs = require 'fs'
path = require 'path'
Handlebars = require 'handlebars'

FORMATS = ['A3', 'A4', 'A5', 'Legal', 'Letter', 'Tabloid']
ORIENTATIONS = ['portrait', 'landscape']
MARGIN_REGEX = /^\d+(in|cm|mm)$/

require('../utils/handlebarsHelpers')(Handlebars)

class Pdf

  constructor: (options = {}) ->
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
    # generate random name / token
    timestamp = new Date().getTime()
    tmpFileName = "#{timestamp}.pdf"
    tmpFilePath = path.join(__dirname, '../../tmp', "#{tmpFileName}.pdf")

    # compile
    html = Handlebars.compile(@_options.content)(@_options.context)

    @_page = null
    try
      ph.createPage (page) =>
        @_page = page
        page.set 'paperSize', @_options.paperSize
        page.setContent html, '', (status) ->
          console.log status
          page.render tmpFilePath, ->
            page.close()
            cb(tmpFileName)
    catch e
      @_page?.close()
      throw new Error e

module.exports = Pdf
