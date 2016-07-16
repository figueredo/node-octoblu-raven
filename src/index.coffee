Express = require './express'
Worker  = require './worker'
debug   = require('debug')('octoblu-raven:index')

class OctobluRaven
  constructor: ({ @release, @dsn } = {}, { @raven } = {}) ->
    @dsn ?= process.env.SENTRY_DSN
    @release ?= process.env.SENTRY_RELEASE
    @raven ?= require 'raven'
    debug 'constructed with', { @dsn, @release }

  express: =>
    new Express { @dsn, @release }, { @raven }

  worker: =>
    new Worker { @dsn, @release }, { @raven }

module.exports = OctobluRaven
