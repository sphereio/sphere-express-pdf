_ = require 'underscore'
fs = require 'fs'
path = require 'path'
phantom = require 'phantom'
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

  generate: (cb) ->
    # generate random name / token
    timestamp = new Date().getTime()
    tmpFileName = "#{timestamp}.pdf"
    tmpFilePath = path.join(__dirname, '../../tmp', "#{tmpFileName}.pdf")

    # compile
    html = Handlebars.compile(@_options.content)(@_options.context)

    phantom.create (ph) =>
      ph.createPage (page) =>
        page.set 'paperSize', @_options.paperSize
        page.setContent html, '', (status) ->
          console.log status
          page.render tmpFilePath, ->
            page.close()
            ph.exit()
            cb(tmpFileName)

module.exports = Pdf
