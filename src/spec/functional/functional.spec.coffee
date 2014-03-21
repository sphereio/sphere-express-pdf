Q = require 'q'
_ = require 'underscore'
uuid = require 'uuid'
helper = require '../SpecHelper'
testData = require '../../data/test.json'

describe 'Functional Spec', ->

  RANDOM_TOKEN = uuid.v4()

  createPdf = (http, data = testData) ->
    d = Q.defer()
    http.post '/api/pdf/url', data
    .then (result) ->
      expect(result.response.statusCode).toBe 200
      expect(result.response.headers['content-type']).toBe 'application/json; charset=utf-8'
      expect(result.body.status).toBe 200
      expect(result.body.expires_in).toBe '???'
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
        expect(result.body.name).toBe 'sphere-express-pdf'
        done()
      .fail (error) -> done(error)

  describe ':: POST /api/pdf/url', ->

    it 'should return url to newly created pdf file', (done) ->
      createPdf helper.http
      .then (filename) -> done()
      .fail (error) -> done(error)

  describe ":: GET /api/pdf/render/:token", ->

    it 'should render pdf', (done) ->
      createPdf helper.http
      .then (filename) ->
        http.get "/api/pdf/render/#{filename}"
      .then (result) ->
        expect(result.response.statusCode).toBe 200
        expect(result.response.headers['content-type']).toBe 'application/pdf'
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)

  describe ":: GET /api/pdf/download/:token", ->

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
        expect(result.body).toBeDefined()
        done()
      .fail (error) -> done(error)

  describe ":: POST /api/pdf/render", ->

    it 'should return endpoint not implemented', (done) ->
      helper.http.post '/api/pdf/render', {}
      .then (result) ->
        expect(result.response.statusCode).toBe 501
        expect(result.response.headers['content-type']).toBe 'application/json; charset=utf-8'
        expect(result.body.message).toBe 'Endpoint not implemented yet'
        done()
      .fail (error) -> done(error)

  describe ":: POST /api/pdf/download", ->

    it 'should return endpoint not implemented', ->
      helper.http.post '/api/pdf/download', {}
      .then (result) ->
        expect(result.response.statusCode).toBe 501
        expect(result.response.headers['content-type']).toBe 'application/json; charset=utf-8'
        expect(result.body.message).toBe 'Endpoint not implemented yet'
        done()
      .fail (error) -> done(error)
