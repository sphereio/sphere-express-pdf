'use strict'

sphere_node_pdf = require('../lib/sphere-node-pdf.js')

describe 'Awesome', ->

  beforeEach (done) ->
    # setup here
    done()

  it 'should print', ->
    expect(sphere_node_pdf.awesome()).toBe 'awesome'
