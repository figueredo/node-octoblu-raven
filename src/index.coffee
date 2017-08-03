_              = require 'lodash'
Raven          = require 'raven'
ExpressHandler = require './express-handler'
debug          = require('debug')('octoblu-raven:index')

class OctobluRaven
  constructor: ({ @dsn, @logFn } = {}) ->
    @logFn ?= console.error
    @dsn ?= process.env.SENTRY_DSN
    debug 'constructed with', { @dsn }
    return if Raven.installed
    Raven.disableConsoleAlerts()
    Raven.config(@dsn).install() if @dsn?

  handleExpress: ({ app }) =>
    throw new Error 'OctobluRaven->express requires app' unless app?
    expressHandler = new ExpressHandler { @dsn, @logFn }
    app.use expressHandler.requestHandler()
    app.use expressHandler.errorHandler()
    app.use expressHandler.sendErrorHandler()

  reportError: (error, extra) =>
    return @logFn error, extra unless @dsn?
    return Raven.captureException error, extra if _.isError error
    return Raven.captureMessage error, extra if _.isString error
    Raven.captureMessage JSON.stringify(error), extra

  patchGlobal: =>
    return unless @dsn?
    Raven.uninstall()
    Raven.install (error) =>
      @logFn error?.stack ? error?.message ? error
      process.exit 1

  off: =>
    Raven.uninstall()

module.exports = OctobluRaven
