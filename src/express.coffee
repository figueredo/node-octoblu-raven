{ STATUS_CODES }  = require 'http'
debug = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven, @client } = {}) ->
    debug 'constructed with', { @dsn, @release }

  requestHandler: =>
    return @_defaultMiddleware() unless @client?
    debug 'requestHandler', { @dsn }
    return @raven.middleware.express.requestHandler @client

  errorHandler: =>
    return @_defaultMiddleware() unless @client?
    debug 'errorHandler', { @dsn }
    return @raven.middleware.express.errorHandler @client

  meshbluAuthContext: =>
    return @_defaultMiddleware() unless @client?
    return (req, res, next) =>
      { uuid } = req.meshbluAuth ? {}
      return next() unless uuid?
      debug 'setting user context', { uuid }
      @client.setUserContext { uuid }
      next()

  sendError: ({logFn=console.error}={}) =>
    debug 'sendError', { @dsn }
    return (request, response, next) =>
      response.sendError = (error) =>
        throw new Error('[octoblu-raven-send-error] sendError called without an error') unless error?
        try
          throw new Error error.message
        catch stackerror
          logFn stackerror.stack
          code = 500
          code = error.code if STATUS_CODES[error.code]?
          @client.captureException stackerror if @client? && code >= 500
          return response.sendStatus(code) unless error.message?
          return response.status(code).send { error: error.message }
      next()

  _defaultMiddleware: () =>
    (req, res, next) =>
      next()

module.exports = Express
