_                 = require 'lodash'
{ STATUS_CODES }  = require 'http'
debug             = require('debug')('octoblu-raven:express')

class Express
  constructor: ({ @raven, @client, @logFn } = {}) ->

  meshbluAuthContext: =>
    debug 'meshbluAuthContext'
    return @_meshbluAuthContext

  _meshbluAuthContext: (request, response, next) =>
    return next() unless @client?
    @client.setUserContext { uuid: request.meshbluAuth?.uuid } if request.meshbluAuth?.uuid?
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
      if _.isError error
        error.code ?= 500
        @_sendErrorToSentry error, request, response
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
    return debug 'error already sent' if response._ravenSentError
    return debug 'missing message' if !data?.error? && !data?.message?
    try
      error = new Error data.error ? data.message
      error.code = response.statusCode
      error.data = data
    catch newError
      error = newError
    @_sendErrorToSentry error, request, response

  _sendErrorToSentry: (error, request, response) =>
    debug 'maybe sending to sentry', error?.code
    return if error?.code < 500
    debug 'sending to sentry'
    response._ravenSentError = true
    @client.captureError error, @raven.parsers.parseRequest request

module.exports = Express
