_                 = require 'lodash'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven, @client, @logFn } = {}) ->

  meshbluAuthContext: =>
    debug 'meshbluAuthContext'
    return @_meshbluAuthContext

  _meshbluAuthContext: (req, res, next) =>
    return next() unless @client?
    { uuid } = req.meshbluAuth ? {}
    return next() unless uuid?
    debug 'setting user context', { uuid }
    @client.setUserContext { uuid }
    next()

  handleErrors: =>
    debug 'handleErrors'
    return @_handleErrors

  _handleErrors: (request, response, next) =>
    return next() unless @client?
    end = response.end
    response.end = (chunk, encoding) =>
      response.end = end
      response.end chunk, encoding
      debug 'on response end'
      @_onFinished response, request, @_parseResponse(chunk)
    next()

  _parseResponse: (data) =>
    try
      json = JSON.parse data
    catch error
      json = JSON.parse JSON.stringify { error: data }
    debug 'parsed data', json
    return json

  _onFinished: (response, request, data) =>
    debug 'handling error', { statusCode: response.statusCode }
    return if response.statusCode < 500
    try
      error = new Error data.error ? data.message
      error.code = response.statusCode
    catch newError
      error = newError
    @_sendErrorToSentry error, request

  _sendErrorToSentry: (error, request) =>
    debug 'sending to sentry'
    @client.captureError error, @raven.parsers.parseRequest request

module.exports = Express
