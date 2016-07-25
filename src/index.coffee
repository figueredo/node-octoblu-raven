_       = require 'lodash'
Express = require './express'
debug   = require('debug')('octoblu-raven:index')

class OctobluRaven
  constructor: ({ @release, @dsn, @name } = {}, { @raven, @logFn } = {}) ->
    @logFn ?= console.error
    @dsn ?= process.env.SENTRY_DSN
    @release ?= process.env.SENTRY_RELEASE
    @name ?= process.env.SENTRY_NAME
    @raven ?= require 'raven'
    @client = @_getClient()
    debug 'constructed with', { @dsn, @release, @name }

  express: =>
    new Express { @raven, @client, @logFn }

  setUserContext: (options) =>
    @client.setUserContext options

  reportError: (error, extra) =>
    return unless @client?
    return @client.captureException error, extra if _.isError error
    return @client.captureMessage error, extra if _.isString error
    @client.captureMessage JSON.stringify(error), extra

  patchGlobal: =>
    return unless @client?
    debug 'setting up patchGlobal'
    @client.patchGlobal (_, error) =>
      debug 'received error', arguments...
      console.error error?.stack ? error?.message ? error
      process.exit 1

  _getClient: =>
    return null unless @dsn?
    options = {}
    options.release = @release if @release?
    options.name = @name if @name?
    return new @raven.Client @dsn, options

module.exports = OctobluRaven
