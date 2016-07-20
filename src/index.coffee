Express = require './express'
Worker  = require './worker'
debug   = require('debug')('octoblu-raven:index')

class OctobluRaven
  constructor: ({ @release, @dsn } = {}, { @raven } = {}) ->
    @dsn ?= process.env.SENTRY_DSN
    @release ?= process.env.SENTRY_RELEASE
    @raven ?= require 'raven'
    @client = @_getClient()
    debug 'constructed with', { @dsn, @release }

  express: ({ logFn }={}) =>
    new Express { @dsn, @release, @client, logFn }, { @raven, @client }

  worker: =>
    new Worker { @dsn, @release }, { @raven, @client }

  _getClient: =>
    return null unless @dsn?
    options = {}
    options.release = @release if @release?
    return new @raven.Client @dsn, options

module.exports = OctobluRaven
