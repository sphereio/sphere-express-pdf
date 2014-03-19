_ = require 'underscore'
fs = require 'fs'
path = require 'path'
moment = require 'moment'
phantom = require 'phantom'
Handlebars = require 'handlebars'

FORMATS = ['A3', 'A4', 'A5', 'Legal', 'Letter', 'Tabloid']
ORIENTATIONS = ['portrait', 'landscape']
MARGIN_REGEX = /^\d+(in|cm|mm)$/

# TERNARY (condition ? a : b)
Handlebars.registerHelper "ternary", (a, b, condition) ->
  if condition and condition.hash
    condition = a

  if condition
    return a
  else
    return b

# FORMAT DATE
Handlebars.registerHelper "formatDate", (value) ->
  moment.utc(value).format("LLLL")

# VALUEKEY return value for given object key
Handlebars.registerHelper 'valueKey', (object, key, placeholder) ->
  if _.isObject(object)
    if object.label
      if _.isObject(object.label)
        value = object.label[key]
      else
        value = object.label
    else if object.centAmount
      value = numbers.formatMoney(object)
    else if object[key]
      value = object[key]
    else value = ""
  else if _.isString(object) or _.isNumber(object)
    value = object
  else value = ""

  unless value
    if placeholder and not placeholder.hash
      if _.isBoolean placeholder
        value = "n/a"
      else
        value = placeholder
    else value = ""
  return value

# FINDBY search and return object by (key, value) from the given list
Handlebars.registerHelper 'findBy', (context, key, value, options) ->
  unless options
    if value
      options = value
    else if key
      options = key
    return options.inverse(this)

  if options.data
    data = Handlebars.createFrame(options.data)

  if context and _.isArray context
    found = _.find(context, (o) -> o[key] is value)
    return options.inverse(this) unless found
    return options.fn(found, { data: data })
  else
    return options.inverse(this)

class Pdf

  constructor: (options = {}) ->
    @_options = _.defaults options,
      paperSize:
        format: 'A4'
        orientation: 'portrait'
        border: '1cm'
      # header: ''
      # footer: ''
      content: ''
      context: {}

  generate: (cb) ->
    # generate random name / token
    timestamp = new Date().getTime()
    tmpFileName = "#{timestamp}.pdf"
    tmpFilePath = path.join(__dirname, '../../tmp', "#{tmpFileName}.pdf")

    # compile
    html = Handlebars.compile(@_options.content)(@_options.context)

    phantom.create (ph) =>
      ph.createPage (page) =>
        page.set 'paperSize', @_options.paperSize
        page.setContent html, '', (status) ->
          console.log status
          page.render tmpFilePath, ->
            page.close()
            ph.exit()
            cb(tmpFileName)

module.exports = Pdf
