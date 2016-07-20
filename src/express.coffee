_                 = require 'lodash'
{ STATUS_CODES }  = require 'http'
debug = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn, @logFn }, { @raven, @client } = {}) ->
    @logFn ?= console.error

  meshbluAuthContext: =>
    return @_defaultMiddleware() unless @client?
    return (req, res, next) =>
      { uuid } = req.meshbluAuth ? {}
      return next() unless uuid?
      debug 'setting user context', { uuid }
      @client.setUserContext { uuid }
      next()

  handleErrors: ({logFn=console.error}={}) =>
    debug 'handleErrors'
    return (request, response, next) =>
      debug 'here'
      response.once 'end', =>
        debug 'handling error', { statusCode: response.statusCode }
        if response.statusCode >= 500
          data = response._getData()
          debug 'response code greater is 500', data
          try
            error = new Error(data.error ? data.message)
            error.code = response.statusCode
          catch newError
            error = newError
          @_sendErrorToSentry error, request, response, next
          return
      next()

  sendError:  =>
    debug 'sendError'
    return (request, response, next) =>
      response.sendError = (error) =>
        debug 'response.sendError called'
        throw new Error('[octoblu-raven] sendError called without an error') unless error?
        error = @_createError error
        debug '_sendError', error
        @logFn error.stack
        @_respondWithError error, request, response, next
      next()

  _createError: (error) =>
    error = new Error(error) if _.isString error
    code = @_getCode error
    message = error.message ? error.error
    unless _.isError error
      try
        throw new Error message
      catch newError
        error = newError
    error.message = message
    error.code = code
    debug 'created error', { code, message }
    return error

  _sendErrorToSentry: (error, request, response, next) =>
    return unless @client?
    return if error.code < 500
    debug 'sending to sentry'
    @client.captureError error, @raven.parsers.parseRequest(request)

  _respondWithError: (error, request, response, next) =>
    debug 'responding with error'
    return next error if response.headersSent
    return response.status(error.code).send { error: error.message } if error.message?
    response.sendStatus(error.code)

  _getCode: (error) =>
    code = error.code
    return code if STATUS_CODES[code]?
    statusCode = error.status || error.statusCode || error.status_code
    return statusCode if STATUS_CODES[statusCode]?
    return 500

  _defaultMiddleware: () =>
    (req, res, next) =>
      next()

module.exports = Express
