fs = require 'fs'
path = require 'path'
phantom = require 'phantom'
Pdf = require '../lib/ws/pdf'
testData = require '../data/test.json'

describe 'Pdf generator', ->

  beforeEach (done) ->
    @expectedPath = null
    phantom.create "--web-security=no", "--ignore-ssl-errors=yes",
      port: 1111
    , (ph) =>
      @_ph = ph
      done()

  afterEach (done) ->
    @_ph.exit()
    fs.unlink @expectedPath, (err) ->
      if err
        done(err)
      else
        done()

  it 'should generate pdf', (done) ->
    pdf = new Pdf testData
    pdf.generate @_ph, (tmpFileName) =>
      @expectedPath = path.join(__dirname, '../tmp', "#{tmpFileName}.pdf")
      fs.readFile @expectedPath, 'utf-8', (err, data) ->
        if err
          done(err)
        else
          expect(data).toBeDefined()
          done()
