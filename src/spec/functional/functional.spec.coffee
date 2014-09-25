Q = require 'q'
_ = require 'underscore'
uuid = require 'uuid'
helper = require '../SpecHelper'
testData = require '../../data/test.json'

describe 'Functional Spec', ->

  RANDOM_TOKEN = uuid.v4()

  checkCORSHeaders = (res) ->
    expect(res.headers['access-control-allow-origin']).toBe '*'
    expect(res.headers['access-control-allow-headers']).toBe 'Accept, Content-Type, Origin'
    expect(res.headers['access-control-allow-methods']).toBe 'GET, POST, OPTIONS'

  createPdf = (http, data = testData) ->
    d = Q.defer()
    http.post '/api/pdf/url', data
    .then (result) ->
      expect(result.response.statusCode).toBe 200
      expect(result.response.headers['content-type']).toBe 'application/json; charset=utf-8'
      checkCORSHeaders(result.response)
      expect(result.body.status).toBe 200
      expect(result.body.expires_in).toBe 1800
      expect(result.body.file).toMatch /(.*).pdf/
      expect(result.body.url).toMatch /http\:\/\/localhost\:3999\/api\/pdf\/(render|download)\/(.*).pdf/
      d.resolve result.body.file
    .fail (error) -> d.reject error
    d.promise

  describe ':: GET /', ->

    it 'should return package info', (done) ->
      helper.http.get '/'
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/json; charset=utf-8'
        checkCORSHeaders(result.response)
        expect(result.body.name).toBe 'sphere-express-pdf'
        done()
      .fail (error) -> done(error)

  describe ':: POST /api/pdf/url', ->

    it 'should return url to newly created pdf file', (done) ->
      createPdf helper.http
      .then (filename) -> done()
      .fail (error) -> done(error)

  describe ":: GET /api/pdf/render/:fileName", ->

    it 'should render pdf', (done) ->
      createPdf helper.http
      .then (filename) ->
        http.get "/api/pdf/render/#{filename}"
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/pdf'
        checkCORSHeaders(result.response)
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)

    it 'should show 404 if pdf is not found', (done) ->
      http.get "/api/pdf/render/not-found.pdf"
      .then (result) ->
        expect(result.response.statusCode).toBe 404
        expect(result.response.headers['content-type']).toBe 'text/html; charset=utf-8'
        checkCORSHeaders(result.response)
        expect(result.body).toBe 'File not-found.pdf not found'
        done()
      .fail (error) -> done(error)

  describe ":: GET /api/pdf/download/:fileName", ->

    it 'should download pdf', (done) ->
      name = null
      createPdf helper.http, _.extend {}, testData, {download: true}
      .then (filename) ->
        name = filename
        http.get "/api/pdf/download/#{filename}"
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/pdf'
        expect(result.response.headers['content-disposition']).toBe "attachment; filename=\"#{name}\""
        checkCORSHeaders(result.response)
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)

    it 'should show 404 if pdf is not found', (done) ->
      http.get "/api/pdf/download/not-found.pdf"
      .then (result) ->
        expect(result.response.statusCode).toBe 404
        expect(result.response.headers['content-type']).toBe 'text/html; charset=utf-8'
        checkCORSHeaders(result.response)
        expect(result.body).toBe 'File not-found.pdf not found'
        done()
      .fail (error) -> done(error)

  describe ":: POST /api/pdf/render", ->

    it 'should return endpoint not implemented', (done) ->
      helper.http.post '/api/pdf/render', testData
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/pdf'
        checkCORSHeaders(result.response)
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)

  describe ":: POST /api/pdf/download", ->

    it 'should return endpoint not implemented', ->
      helper.http.post '/api/pdf/download', testData
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/pdf'
        expect(result.response.headers['content-disposition']).toBe "attachment; filename=\"#{name}\""
        checkCORSHeaders(result.response)
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)
