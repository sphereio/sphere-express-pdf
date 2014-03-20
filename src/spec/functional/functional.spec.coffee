helper = require '../SpecHelper'

describe 'Functional Spec:', ->

  describe "routes.index", ->

    it "should return package info", ->
      helper.withServer (r, done) ->
        r.get "/", (data) ->
          expect(data.name).toBe 'express-pdf'
          done()
