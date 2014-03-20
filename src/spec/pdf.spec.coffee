fs = require 'fs'
path = require 'path'
Pdf = require '../lib/ws/pdf'
testData = require '../data/test.json'

describe 'Pdf generator', ->

  beforeEach ->
    @expectedPath = null

  afterEach (done) ->
    fs.unlink @expectedPath, (err) ->
      if err
        done(err)
      else
        done()

  it 'should generate pdf', (done) ->
    pdf = new Pdf testData
    pdf.generate (tmpFileName) =>
      @expectedPath = path.join(__dirname, '../tmp', "#{tmpFileName}.pdf")
      fs.readFile @expectedPath, 'utf-8', (err, data) ->
        if err
          done(err)
        else
          expect(data).toBeDefined()
          done()
