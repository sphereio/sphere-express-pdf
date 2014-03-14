# express-pdf

Run a Restlet webserver to generate PDFs from HTML, using phantom.js

> Inspired from [html2pdf.it](https://github.com/emmenko/html2pdf.it)

## Getting Started
Install the module with: `npm install express-pdf`

> Make sure to have [phantom.js](http://phantomjs.org/) installed

```bash
$ brew install phantom
```

Start the webserver

```bash
$ grunt run
```

## Documentation
_(Coming soon)_

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
