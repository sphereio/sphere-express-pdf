_ = require 'underscore'
moment = require 'moment'

module.exports = (hb) ->

  # TERNARY (condition ? a : b)
  hb.registerHelper "ternary", (a, b, condition) ->
    if condition and condition.hash
      condition = a

    if condition
      return a
    else
      return b

  # FORMAT DATE
  hb.registerHelper "formatDate", (value, format) ->
    format = "LLLL" unless _.isString(format)
    moment.utc(value).format(format)

  # VALUEKEY return value for given object key
  hb.registerHelper 'valueKey', (object, key, placeholder) ->
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
  hb.registerHelper 'findBy', (context, key, value, options) ->
    unless options
      if value
        options = value
      else if key
        options = key
      return options.inverse(this)

    if options.data
      data = hb.createFrame(options.data)

    if context and _.isArray context
      found = _.find(context, (o) -> o[key] is value)
      return options.inverse(this) unless found
      return options.fn(found, { data: data })
    else
      return options.inverse(this)
