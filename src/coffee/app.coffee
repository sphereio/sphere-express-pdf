phantom = require 'phantom'
fs = require 'fs'

path = "#{__dirname}/../data/return.html"

phantom.create (ph) ->
  ph.createPage (page) ->
    console.log path
    fs.readFile path, 'utf-8', (err, data) ->
      page.set 'paperSize',
        format: 'A4'
        orientation: 'portrait'
        border: '1cm'
      page.setContent data, '', (status) ->
        console.log status
        page.render './tmp/file.pdf'
        ph.exit()
