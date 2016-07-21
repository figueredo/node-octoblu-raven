_                 = require 'lodash'
onFinished        = require 'on-finished'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven, @client } = {}) ->

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
    onFinished response, @_onFinished(request)
    next()

  _onFinished: (request) =>
    return (error, response) =>
      return @_sendErrorToSentry error, request if error?
      debug 'handling error', { statusCode: response.statusCode }
      return if response.statusCode < 500
      data = response._getData()
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
