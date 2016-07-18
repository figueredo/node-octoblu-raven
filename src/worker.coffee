debug = require('debug')('octoblu-raven:worker')

class Worker
  constructor: ({ @release, @dsn }, { @raven } = {}) ->
    debug 'constructed with', { @dsn, @release }

  handleErrors: =>
    return unless @dsn?
    debug 'handleErrors', { @dsn }
    options = {}
    options.release = @release if @release?
    client = new @raven.Client @dsn, options
    debug 'setting up patchGlobal'
    client.patchGlobal (_, error) =>
      debug 'received error', arguments...
      console.error error?.stack ? error?.message ? error
      process.exit 1

module.exports = Worker
