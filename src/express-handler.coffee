_                 = require 'lodash'
errorhandler      = require 'errorhandler'
Raven             = require 'raven'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @dsn, @logFn } = {}) ->

  errorHandler: =>
    debug 'errorHandler'
    return errorhandler() unless @dsn?
    return Raven.errorHandler()

  requestHandler: =>
    debug 'requestHandler'
    return @_fakeIt() unless @dsn?
    return Raven.requestHandler()

  sendErrorHandler: =>
    debug 'sendErrorHandler'
    return @_sendErrorHandler

  _sendErrorHandler: (request, response, next) =>
    debug '_sendErrorHandler'
    response.sendError = (error, code) =>
      @_logError error
      code ?= @_getCode(error)
      response.status(code).send @_getResponseMessage(error, code)
    next()

  _logError: (error) =>
    message = _.get(error, 'stack', error)
    return debug message if @_getCode(error) < 500
    @logFn message

  _getError: (error) =>
    return new Error '[octoblu-raven] sendError called without an error' unless error?
    return error if _.isError error
    return new Error @_getMessage(error)

  _getErrorWithCode: (error) =>
    error = @_getError error
    error.code = @_getCode error
    return error

  _getResponseMessage: (error, code) =>
    return error if !_.isError(error) && _.isPlainObject(error)
    message = @_getMessage error, code
    return STATUS_CODES[code] unless message
    return { error: message }

  _getMessage: (error) =>
    return error if _.isString error
    return if error?.message == '[object Object]'
    return unless error?.message
    return error.message

  _getCode: (error) =>
    code = _.get error, 'code'
    try
      code = _.toNumber code
    return error.code if STATUS_CODES[code]?
    return 500

  _fakeIt: =>
    return (request, response, next) =>
      next()

module.exports = Express
