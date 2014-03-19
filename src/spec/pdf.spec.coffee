fs = require 'fs'
path = require 'path'
Pdf = require '../lib/ws/pdf'

describe 'Pdf generator', ->

  beforeEach (done) ->
    @expectedPath = null
    templatePath = path.join(__dirname, '../data', 'test-template.html')
    fs.readFile templatePath, 'utf-8', (err, data) =>
      @body =
        paperSize:
          format: 'A4'
          orientation: 'portrait'
          border: '1cm'
        content: data
        context:
          title: 'Hello world'
        download: false
      done()

  afterEach (done) ->
    fs.unlink @expectedPath, (err) ->
      if err
        done(err)
      else
        done()

  it 'should generate pdf', (done) ->
    pdf = new Pdf @body
    pdf.generate (tmpFileName) =>
      @expectedPath = path.join(__dirname, '../tmp', "#{tmpFileName}.pdf")
      fs.readFile @expectedPath, 'utf-8', (err, data) ->
        if err
          done(err)
        else
          expect(data).toBeDefined()
          done()
