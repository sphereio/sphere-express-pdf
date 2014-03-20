uuid = require 'uuid'
helper = require '../SpecHelper'
testData = require '../../data/test.json'

describe 'Functional Spec', ->

  RANDOM_TOKEN = uuid.v4()

  describe ':: GET /', ->

    it 'should return package info', ->
      helper.withServer (r, done) ->
        r.get '/', (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 200
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.name).toBe 'sphere-express-pdf'
            done()

  describe ':: POST /api/pdf/url', ->

    it 'should return url to newly created pdf file', ->
      helper.withServer (r, done) ->
        r.post '/api/pdf/url', testData, (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 200
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.status).toBe 200
            expect(b.expires_in).toBe '???'
            expect(b.url).toMatch /http\:\/\/localhost\:3999\/api\/pdf\/render\/(.*).pdf/
            done()

  describe ":: GET /api/pdf/render/#{RANDOM_TOKEN}", ->

    it 'should return endpoint not implemented', ->
      helper.withServer (r, done) ->
        r.get "/api/pdf/render/#{RANDOM_TOKEN}", (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 501
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.message).toBe 'Endpoint not implemented yet'
            done()

  describe ":: GET /api/pdf/download/#{RANDOM_TOKEN}", ->

    it 'should return endpoint not implemented', ->
      helper.withServer (r, done) ->
        r.get "/api/pdf/download/#{RANDOM_TOKEN}", (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 501
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.message).toBe 'Endpoint not implemented yet'
            done()

  describe ":: POST /api/pdf/render", ->

    it 'should return endpoint not implemented', ->
      helper.withServer (r, done) ->
        r.post '/api/pdf/render', {}, (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 501
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.message).toBe 'Endpoint not implemented yet'
            done()

  describe ":: POST /api/pdf/download", ->

    it 'should return endpoint not implemented', ->
      helper.withServer (r, done) ->
        r.post '/api/pdf/download', {}, (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 501
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.message).toBe 'Endpoint not implemented yet'
            done()
