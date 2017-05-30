![commercetools logo](https://cdn.rawgit.com/commercetools/press-kit/master/PNG/72DPI/CT%20logo%20horizontal%20RGB%2072dpi.png)

# Express PDF

[![Build Status](https://travis-ci.org/sphereio/sphere-express-pdf.svg?branch=master)](https://travis-ci.org/sphereio/sphere-express-pdf) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-express-pdf/badge.png?branch=master)](https://coveralls.io/r/sphereio/sphere-express-pdf?branch=master) [![Dependency Status](https://david-dm.org/sphereio/sphere-express-pdf.svg?theme=shields.io)](https://david-dm.org/sphereio/sphere-express-pdf) [![devDependency Status](https://david-dm.org/sphereio/sphere-express-pdf/dev-status.svg?theme=shields.io)](https://david-dm.org/sphereio/sphere-express-pdf#info=devDependencies)

Run a Restlet webserver to generate PDFs from HTML, using phantom.js

> Inspired from [html2pdf.it](https://github.com/Muscula/html2pdf.it)

## Getting Started

> Make sure to have [phantom.js](http://phantomjs.org/) installed

```bash
$ brew install phantom

# or

$ npm i -g phantomjs-prebuilt
$ npm rebuild
```

Start the webserver

```bash
$ npm start
# or
$ grunt run # will watch for changes and keep the server alive
```

To run it on **production** set the environment

```bash
$ NODE_ENV=production npm start
```

You can also pipe the logs (pretty printed) with `bunyan`

```bash
$ npm start | bunyan -o short

> sphere-express-pdf@0.1.0 start /Users/nicola/dev/src/sphere-express-pdf
> node ./lib/app.js

11:02:04.039Z  INFO sphere-express-pdf: Starting express application on port 3999 (development)
11:02:04.260Z  INFO sphere-express-pdf: Listening for HTTP on http://localhost:3999
...
```

## Documentation
The webserver started by express.js offers some JSON endpoints to work with PDFs.
There are 2 basic principles regarding the endpoints:

- `POST` some data which will be used to generate a PDF
- `GET` the generated PDF in different ways

### Request body
```javascript
// defaults
{
  "paperSize": {
    "format": "A4", // possible values ['A3', 'A4', 'A5', 'Legal', 'Letter', 'Tabloid']
    "orientation": "portrait", // possible values ['portrait', 'landscape']
    "border": "1cm", // possible units ['mm', 'cm', 'in', 'px']
  },
  "content": "", // an HTML string with Handlebars template syntax
  "context": {}, // a JSON object used to pass as context in the template
  "download": false // true if the url link should trigger a PDF download, otherwise it will be rendered in the browser
}
```

### API

##### POST `/api/pdf/url`
Will generate a PDF based on the given `payload` data and returns a JSON with a
link to the PDF.
> Note that the link will **expire** after some time

```javascript
// response
{
  status: 200,
  expires_in: '',
  file: '1234567890.pdf',
  url: 'http://localhost:3999/api/pdf/render/1234567890.pdf'
}
```

##### POST `/api/pdf/render`
Will generate a PDF based on the given `payload` data and render it in the browser

##### POST `/api/pdf/download`
Will generate a PDF based on the given `payload` data and download it

##### GET `/api/pdf/render/:fileName`
Will render in the browser the generated PDF, if the token is still valid

##### GET `/api/pdf/download/:fileName`
Will download the generated PDF, if the token is still valid


## Examples

```json
{
  "paperSize": {
    "format": "A4",
    "orientation": "portrait",
    "border": "1cm",
  },
  "content": "
    <html>
      <head>
        <meta charset=\"utf-8\">
        <title>A PDF page</title>
        <style type=\"text/css\">
          body { font-family: \"Helvetica New\", Helvetica, Arial, sans-serif; font-size: 12px; }
          h1 { text-transform: uppercase; }
        </style>
      </head>
      <body>
        <h1>{{title}}</h1>
        <h2>{{formatDate createdAt}}</h2>
      </body>
    </html>
  ",
  "context": {
    "title": "Hello world",
    "createdAt": "2014-01-20T19:18:42.940Z"
  },
  "download": false
}
```

## Cleanup expired PDFs
By default PDFs are stored into `./tmp` folder but are not removed automatically.
There is a `clean.sh` script available that checks for expired PDFs (**30min**) and optionally remove them.

```bash
# check
$ ./bin/clean.sh

Found 3 expired PDFs
1395745335088-e97e7060da8196e1a58016637f86f80c385546edbc30f8540a8bdd8d99fcc4de.pdf
1395745341238-b5712ca71084f0690f5183f30de752c97b04891d3e22106ee1ecccf2218347ae.pdf
1395745341256-38eaa42514c503c64034249e239ad1a76be227af2c0d6573f6d759f96c303850.pdf
To remove the expired files pass the option -d

# check and remove
$ ./bin/clean.sh -d

Found 3 expired PDFs
Removing 1395745335088-e97e7060da8196e1a58016637f86f80c385546edbc30f8540a8bdd8d99fcc4de.pdf...done!
Removing 1395745341238-b5712ca71084f0690f5183f30de752c97b04891d3e22106ee1ecccf2218347ae.pdf...done!
Removing 1395745341256-38eaa42514c503c64034249e239ad1a76be227af2c0d6573f6d759f96c303850.pdf...done!
```

You can setup a cronjob to have this automatically executed

```bash
$ crontab -e
*/5 * * * * /path/to/script/clean.sh
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
More info [here](CONTRIBUTING.md)

## License
Copyright (c) 2014 Nicola Molinari
Licensed under the MIT license.
