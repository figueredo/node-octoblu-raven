_                = require 'lodash'
request          = require 'request'
{ STATUS_CODES } = require 'http'
raven            = require 'raven'
ExpressServer    = require './express-server'
OctobluRaven     = require '../'

describe 'Express Errors', ->
  beforeEach ->
    dsn = 'https://xxx:xxx@app.getsentry.com/87213'
    @client = new raven.Client dsn
    @client.captureError = sinon.stub().yields { something: true }
    @client.captureMessage = sinon.stub().yields { something: true }
    @logFn = sinon.spy()
    @octobluRaven = new OctobluRaven({ dsn, release: 'v1.0.0' }, { @client, @logFn })
    @server = new ExpressServer { @octobluRaven }

  afterEach ->
    @server.destroy()

  describe 'GET /blowup', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal STATUS_CODES[500]

    it 'should log the message with sentry', ->
      expect(@client.captureMessage).to.have.been.calledWith 'Internal Server Error: 500'

  describe 'GET /blowup/504', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/504'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 504', ->
      expect(@response.statusCode).to.equal 504

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal STATUS_CODES[504]

    it 'should log the message with sentry', ->
      expect(@client.captureMessage).to.have.been.calledWith 'Gateway Timeout: 504'

  describe 'GET /blowup/422', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/422'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 422', ->
      expect(@response.statusCode).to.equal 422

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal STATUS_CODES[422]

    it 'should not log the message with sentry', ->
      expect(@client.captureMessage).to.not.have.been.called

  describe 'GET /blowup/sendError', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendError'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal error: 'oh no error'

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.have.been.called

    it 'should log the error', ->
      expect(@logFn).to.have.been.called

  describe 'GET /blowup/sendUserError', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendUserError'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 429', ->
      expect(@response.statusCode).to.equal 429

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal error: 'oh no user error'

    it 'should not log the error with sentry', ->
      expect(@client.captureError).to.not.have.been.called

    it 'should log not log the error', ->
      expect(@logFn).to.not.have.been.called

  describe 'GET /blowup/sendError/no-code', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendError/no-code'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal error: 'oh no error'

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.have.been.called

  describe 'GET /blowup/sendError/error-object', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendError/error-object'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal STATUS_CODES[500]

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.have.been.called

  describe 'GET /blowup/sendError/string', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendError/string'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal error: 'oh no error'

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.have.been.called

  describe 'GET /blowup/sendError/object', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/sendError/object'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal oh: no: 'error'

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.have.been.called

  describe 'GET /blowup/error', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/error'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal error: 'oh no error'

    it 'should log the message with sentry', ->
      expect(@client.captureMessage).to.have.been.calledWith "#{STATUS_CODES[500]}: 500"

  describe 'GET /blowup/object', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/blowup/object'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal oh: no: 'error'

    it 'should log the message with sentry', ->
      expect(@client.captureMessage).to.have.been.calledWith "#{STATUS_CODES[500]}: 500"

  describe 'GET /success', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/success'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should yield the correct error response', ->
      expect(@body).to.equal STATUS_CODES[200]

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.not.have.been.called

  describe 'GET /success/string', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/success/string'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should yield the correct error response', ->
      expect(@body).to.equal 'success'

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.not.have.been.called

  describe 'GET /success/object', ->
    beforeEach (done) ->
      @server.start done

    beforeEach (done) ->
      options = {
        baseUrl: @server.baseUrl()
        uri: '/success/object'
        json: true,
      }
      request.get options, (error, @response, @body) =>
        done error

    it 'should yield a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should yield the correct error response', ->
      expect(@body).to.deep.equal success: true

    it 'should log the error with sentry', ->
      expect(@client.captureError).to.not.have.been.called
