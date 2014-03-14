_ = require 'underscore'
fs = require 'fs'
path = require 'path'
phantom = require 'phantom'

FORMATS = ['A3', 'A4', 'A5', 'Legal', 'Letter', 'Tabloid']
ORIENTATIONS = ['portrait', 'landscape']
MARGIN_REGEX = /^\d+(in|cm|mm)$/

html_file = path.join(__dirname, '../../data', 'return.html')


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

    phantom.create (ph) =>
      ph.createPage (page) =>
        console.log html_file
        fs.readFile html_file, 'utf-8', (err, data) =>
          page.set 'paperSize', @_options.paperSize
          page.setContent data, '', (status) ->
            console.log status
            page.render tmpFilePath, ->
              page.close()
              ph.exit()
              cb(tmpFileName)

module.exports = Pdf
