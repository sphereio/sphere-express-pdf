fs = require 'fs'
phantom = require 'phantom'

path = "#{__dirname}/../data/return.html"

# app = express()

# app.get '/', (req, res) ->
#   res.send """
# <!DOCTYPE html>
# <html>
#   <head></head>
#   <body>
#     <h1>Hello world</h1>
#     <a id="btn">Click me</a>
#     <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
#     <script type="text/javascript">
#       $(document).ready(function(){
#         $('#btn').click(function(evt){
#           window.open('/pdf', '_blank')
#         })
#       })
#     </script>
#   </body>
# </html>
#   """
# app.get '/pdf', (req, res) -> renderPdf(req, res)

# server = app.listen 3000, ->
#   console.log('Listening on port %d', server.address().port)

# renderPdf = (req, res) ->
#   phantom.create (ph) ->
#     ph.createPage (page) ->
#       console.log path
#       fs.readFile path, 'utf-8', (err, data) ->
#         page.set 'paperSize',
#           format: 'A4'
#           orientation: 'portrait'
#           border: '1cm'
#         page.setContent data, '', (status) ->
#           console.log status
#           page.render './tmp/file.pdf', ->
#             page.close()
#             ph.exit()
#             res.download './tmp/file.pdf'
