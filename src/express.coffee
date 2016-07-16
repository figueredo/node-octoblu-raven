debug = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven } = {}) ->
    debug 'constructed with', { @dsn, @release }

  requestHandler: =>
    return @_defaultMiddleware() unless @dsn?
    debug 'requestHandler', { @dsn }
    @raven.middleware.express.requestHandler @dsn

  errorHandler: =>
    return @_defaultMiddleware() unless @dsn?
    debug 'errorHandler', { @dsn }
    @raven.middleware.express.errorHandler @dsn

  _defaultMiddleware: () =>
    (req, res, next) =>
      next()

module.exports = Express
