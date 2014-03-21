![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# Express PDF

[![Build Status](https://travis-ci.org/sphereio/sphere-express-pdf.svg?branch=master)](https://travis-ci.org/sphereio/sphere-express-pdf) [![Coverage Status](https://coveralls.io/repos/sphereio/sphere-express-pdf/badge.png?branch=master)](https://coveralls.io/r/sphereio/sphere-express-pdf?branch=master) [![Dependency Status](https://david-dm.org/sphereio/sphere-express-pdf.svg?theme=shields.io)](https://david-dm.org/sphereio/sphere-express-pdf) [![devDependency Status](https://david-dm.org/sphereio/sphere-express-pdf/dev-status.svg?theme=shields.io)](https://david-dm.org/sphereio/sphere-express-pdf#info=devDependencies)

Run a Restlet webserver to generate PDFs from HTML, using phantom.js

> Inspired from [html2pdf.it](https://github.com/Muscula/html2pdf.it)

## Getting Started
Install the module with: `npm install sphere-express-pdf`

> Make sure to have [phantom.js](http://phantomjs.org/) installed

```bash
$ brew install phantom
```

Start the webserver

```bash
$ npm start
# or
$ grunt run # will watch for changes and keep the server alive
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
Will generate a PDF based on the given `paylod` data and returns a JSON with a
link to the PDF.
> Note that the link will expire after some time

```javascript
// response
{
  status: 200,
  expires_in: '',
  url: 'http://localhost:3000/api/pdf/render/1234567890.pdf'
}
```

##### POST `/api/pdf/render`
Will generate a PDF based on the given `paylod` data and render it in the browser

##### POST `/api/pdf/download`
Will generate a PDF based on the given `paylod` data and download it

##### GET `/api/pdf/render/:token`
Will render in the browser the generated PDF, if the token is still valid

##### GET `/api/pdf/download/:token`
Will download the generated PDF, if the token is still valid


## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
More info [here](CONTRIBUTING.md)

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## License
Copyright (c) 2014 Nicola Molinari
Licensed under the MIT license.
