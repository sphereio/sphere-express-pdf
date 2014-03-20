helper = require '../SpecHelper'
testData = require '../../data/test.json'

describe 'Functional Spec', ->

  describe ':: GET /', ->

    it 'should return package info', ->
      helper.withServer (r, done) ->
        r.get '/', (e, r, b) ->
          if e
            done(e)
          else
            expect(r.statusCode).toBe 200
            expect(r.headers['content-type']).toBe 'application/json; charset=utf-8'
            expect(b.name).toBe 'express-pdf'
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
