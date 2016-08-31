_                 = require 'lodash'
onFinished        = require 'on-finished'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @raven, @client, @logFn } = {}) ->

  meshbluAuthContext: =>
    debug 'meshbluAuthContext'
    return @_meshbluAuthContext

  errorHandler: =>
    debug 'errorHandler'
    return @raven.middleware.express.errorHandler @client

  requestHandler: =>
    debug 'requestHandler'
    return @raven.middleware.express.requestHandler @client

  badRequestHandler: =>
    debug 'badRequestHandler'
    return @_badRequestHandler

  sendErrorHandler: =>
    debug 'sendErrorHandler'
    return @_sendErrorHandler

  _meshbluAuthContext: (request, response, next) =>
    debug '_meshbluAuthContext', request.meshbluAuth?.uuid
    @client.setUserContext { uuid: request.meshbluAuth?.uuid } if request.meshbluAuth?.uuid?
    next()

  _badRequestHandler: (request, response, next) =>
    debug '_badRequestHandler'
    onFinished response, (error, response) =>
      code = response.statusCode
      return if code < 500
      @_captureMessage "#{STATUS_CODES[code]}: #{code}", request, response
    next()

  _sendErrorHandler: (request, response, next) =>
    debug '_sendErrorHandler'
    response.sendError = (error) =>
      try
        throw @_getError error
      catch stackerror
        @logFn stackerror.stack
      code = @_getCode error
      @_captureError error, code, request, response, =>
        response.status(code).send @_getResponseMessage(error, code)
    next()

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
    return error.code if STATUS_CODES[error?.code]?
    return 500

  _captureError: (error, code, request, response, callback) =>
    return callback null unless @client?
    if response.sentry?
      debug '_captureError already sent'
      callback null
      return
    if error.code < 500
      debug '_captureError non-500 level error'
      callback null
      return
    debug '_captureError'
    kwargs = @raven.parsers.parseRequest request
    @raven.parsers.parseError error, kwargs, (kwargs) =>
      @client.captureError error, kwargs, (result) =>
        response.sentry = @client.getIdent result
        callback null

  _captureMessage: (message, request, response) =>
    return unless @client?
    debug '_captureMessage', message
    return debug '_captureMessage already sent' if response.sentry?
    kwargs = @raven.parsers.parseRequest request
    @client.captureMessage message, kwargs, (result) =>
      response.sentry = @client.getIdent result

module.exports = Express
