Express = require './express'
debug   = require('debug')('octoblu-raven:index')

class OctobluRaven
  constructor: ({ @release, @dsn } = {}, { @raven, @logFn } = {}) ->
    @logFn ?= console.error
    @dsn ?= process.env.SENTRY_DSN
    @release ?= process.env.SENTRY_RELEASE
    @raven ?= require 'raven'
    @client = @_getClient()
    debug 'constructed with', { @dsn, @release }

  express: =>
    new Express { @dsn, @release, @client }, { @raven, @client, @logFn }

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
    return new @raven.Client @dsn, options

module.exports = OctobluRaven
