{ STATUS_CODES }  = require 'http'
debug = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven } = {}) ->
    debug 'constructed with', { @dsn, @release }

  requestHandler: =>
    return @_defaultMiddleware() unless @dsn?
    debug 'requestHandler', { @dsn }
    return @raven.middleware.express.requestHandler @dsn

  errorHandler: =>
    return @_defaultMiddleware() unless @dsn?
    debug 'errorHandler', { @dsn }
    return @raven.middleware.express.errorHandler @dsn

  sendError: ({logFn=console.error}={}) =>
    debug 'sendError', { @dsn }
    client = @_getClient()
    return (request, response, next) =>
      response.sendError = (error) =>
        throw new Error('[octoblu-raven-send-error] sendError called without an error') unless error?
        try
          throw new Error error.message
        catch stackerror
          logFn stackerror.stack
          code = 500
          code = error.code if STATUS_CODES[error.code]?
          client.captureException stackerror if client? && code >= 500
          return response.sendStatus(code) unless error.message?
          return response.status(code).send { error: error.message }
      next()

  _getClient: =>
    return null unless @dsn?
    options = {}
    options.release = @release if @release?
    return new @raven.Client @dsn, options

  _defaultMiddleware: () =>
    (req, res, next) =>
      next()

module.exports = Express
