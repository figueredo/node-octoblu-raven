_                 = require 'lodash'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @release, @dsn }, { @raven, @client, @logFn } = {}) ->

  meshbluAuthContext: =>
    debug 'meshbluAuthContext'
    return @_meshbluAuthContext

  _meshbluAuthContext: (request, response, next) =>
    return next() unless @client?
    ended = false
    checkForMeshbluAuth = =>
      return if ended
      debug 'request.meshbluAuth', request.meshbluAuth?.uuid?
      return @client.setUserContext { uuid: request.meshbluAuth?.uuid } if request.meshbluAuth?.uuid?
      debug 'checking for meshblu auth error again'
      _.delay checkForMeshbluAuth, 2
    checkForMeshbluAuth()
    end = response.end
    response.end = (chunk, encoding) =>
      response.end = end
      response.end chunk, encoding
      ended = true
    next()

  handleErrors: =>
    debug 'handleErrors'
    return @_handleErrors

  _handleErrors: (request, response, next) =>
    return next() unless @client?
    ended = false
    checkSendError = =>
      return if ended
      return if response._ravenSentError
      debug 'response.sendError', response.sendError?
      return @_overrideSendError response, request if response.sendError?
      debug 'checking for send error again'
      _.delay checkSendError, 2
    checkSendError()
    end = response.end
    response.end = (chunk, encoding) =>
      response.end = end
      response.end chunk, encoding
      debug 'on response end'
      ended = true
      @_onFinished request, response, @_parseResponse(chunk)
    next()

  _overrideSendError: (response, request) =>
    return unless response.sendError?
    debug 'overriding send error'
    response._sendError = response.sendError
    response.sendError = (error) =>
      @_sendErrorToSentry error, request, response if _.isError error
      response._sendError arguments...

  _parseResponse: (data) =>
    try
      json = JSON.parse data
    catch error
      json = JSON.parse JSON.stringify { error: data }
    debug 'parsed data', json
    return json

  _onFinished: (request, response, data) =>
    debug 'handling error', { statusCode: response.statusCode }
    return if response._ravenSentError
    try
      error = new Error data.error ? data.message
      error.code = response.statusCode
      error.data = data
    catch newError
      error = newError
    @_sendErrorToSentry error, request, response

  _sendErrorToSentry: (error, request, response) =>
    debug 'sending to sentry'
    return if error?.code < 500
    response._ravenSentError = true
    @client.captureError error, @raven.parsers.parseRequest request

module.exports = Express
