debug = require('debug')('octoblu-raven:worker')

class Worker
  constructor: ({ @release, @dsn }, { @raven, @client } = {}) ->

  handleErrors: =>
    return unless @client?
    debug 'setting up patchGlobal'
    @client.patchGlobal (_, error) =>
      debug 'received error', arguments...
      console.error error?.stack ? error?.message ? error
      process.exit 1

module.exports = Worker
