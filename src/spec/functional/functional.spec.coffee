helper = require '../SpecHelper'

describe 'Functional Spec:', ->

  describe "routes.index", ->

    it "should return package info", ->
      helper.withServer (r, done) ->
        r.get "/", (res) ->
          expect(res.statusCode).toBe 200
          expect(res.headers['content-type']).toBe 'application/json; charset=utf-8'
          res.setEncoding('utf-8')
          res.on 'data', (chunk) ->
            data = JSON.parse chunk
            expect(data.name).toBe 'express-pdf'
            done()
