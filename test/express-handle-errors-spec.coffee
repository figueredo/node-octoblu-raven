_                = require 'lodash'
{ EventEmitter } = require 'events'
request          = require 'request'
shmock           = require 'shmock'
sendError        = require 'express-send-error'
enableDestroy    = require 'server-destroy'
{ STATUS_CODES } = require 'http'
OctobluRaven     = require '../'

describe 'Express->handleErrors', ->
  beforeEach ->
    @client =
      captureError: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client
      parsers:
        parseRequest: sinon.stub().returns { some: 'thing' }

    @consoleError = sinon.spy()
    @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express()
    @port = 0xd00d
    @baseUrl = "http://localhost:#{@port}"
    @server = shmock @port, [@sut.handleErrors(), sendError()]
    enableDestroy @server

  afterEach (done) ->
    @server.destroy done

  describe 'called with a error middleware', ->
    describe 'when a 500 error response is made', ->
      beforeEach (done) ->
        @server
          .get '/blowup'
          .reply 500, { error: 'oh no 500' }

        options = {
          @baseUrl,
          uri: '/blowup'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 500', ->
        expect(@response.statusCode).to.equal 500

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 500'

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal 'oh no 500'
        expect(@client.captureError.getCall(0).args[0].code).to.equal 500
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.called

    describe 'when a 502 error response is made', ->
      beforeEach (done) ->
        @server
          .get '/blowup'
          .reply 502, { error: 'oh no 502' }

        options = {
          @baseUrl,
          uri: '/blowup'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 502', ->
        expect(@response.statusCode).to.equal 502

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 502'

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal 'oh no 502'
        expect(@client.captureError.getCall(0).args[0].code).to.equal 502
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.called

    describe 'when response.sendError is called', ->
      afterEach ->
        @sendErrorServer.destroy()

      beforeEach (done) ->
        routeHandler = (request, response) =>
          error = new Error 'oh no 504'
          error.code = 504
          response.sendError error

        @sendErrorServer = shmock 0xbabe, [sendError({logFn: @consoleError}), @sut.handleErrors(), routeHandler]
        enableDestroy @sendErrorServer

        @sendErrorServer
          .get '/send-error'
          .delay 100
          .reply 200, { does: not: 'matter' }

        options = {
          baseUrl: "http://localhost:#{0xbabe}",
          uri: '/send-error'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 504', ->
        expect(@response.statusCode).to.equal 504

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 504'

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal 'oh no 504'
        expect(@client.captureError.getCall(0).args[0].code).to.equal 504
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.called

    describe 'when response.sendError is called with a 422', ->
      afterEach ->
        @sendErrorServer.destroy()

      beforeEach (done) ->
        routeHandler = (request, response) =>
          error = new Error 'oh no 422'
          error.code = 422
          response.sendError error

        @sendErrorServer = shmock 0xbabe, [sendError({logFn: @consoleError}), @sut.handleErrors(), routeHandler]
        enableDestroy @sendErrorServer

        @sendErrorServer
          .get '/send-error'
          .delay 100
          .reply 200, { does: not: 'matter' }

        options = {
          baseUrl: "http://localhost:#{0xbabe}",
          uri: '/send-error'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 422', ->
        expect(@response.statusCode).to.equal 422

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 422'

      it 'should not log the error with sentry', ->
        expect(@client.captureError).to.not.have.been.called

      it 'should not parse the request', ->
        expect(@raven.parsers.parseRequest).to.not.have.been.called

    describe 'when response.sendError is called and the middleware is a different order', ->
      afterEach ->
        @sendErrorServer.destroy()

      beforeEach (done) ->
        routeHandler = (request, response) =>
          error = new Error 'oh no 504'
          error.code = 504
          response.sendError error

        @sendErrorServer = shmock 0xbabe, [@sut.handleErrors(), sendError({logFn: @consoleError}), routeHandler]
        enableDestroy @sendErrorServer

        @sendErrorServer
          .get '/send-error'
          .delay 100
          .reply 200, { does: not: 'matter' }

        options = {
          baseUrl: "http://localhost:#{0xbabe}",
          uri: '/send-error'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 504', ->
        expect(@response.statusCode).to.equal 504

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 504'

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal 'oh no 504'
        expect(@client.captureError.getCall(0).args[0].code).to.equal 504
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.called

    describe 'when a 422 error response is made', ->
      beforeEach (done) ->
        @server
          .get '/semibad'
          .reply 422, { error: 'oh no 422' }

        options = {
          @baseUrl,
          uri: '/semibad'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 422', ->
        expect(@response.statusCode).to.equal 422

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal error: 'oh no 422'

      it 'should not log the error with sentry', ->
        expect(@client.captureError).to.not.have.been.called

      it 'should not parse the request', ->
        expect(@raven.parsers.parseRequest).to.not.have.been.called

    describe 'when a 200 with non-json body is made', ->
      beforeEach (done) ->
        @server
          .get '/non-json'
          .reply 200, 'not a problem'

        options = {
          @baseUrl,
          uri: '/non-json'
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 200', ->
        expect(@response.statusCode).to.equal 200

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal 'not a problem'

      it 'should not log the error with sentry', ->
        expect(@client.captureError).to.not.have.been.called

      it 'should not parse the request', ->
        expect(@raven.parsers.parseRequest).to.not.have.been.called

    describe 'when a 200 response is made', ->
      beforeEach (done) ->
        @server
          .get '/okie'
          .reply 200, { this: 'is crazy' }

        options = {
          @baseUrl,
          uri: '/okie'
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 200', ->
        expect(@response.statusCode).to.equal 200

      it 'should yield the correct error response', ->
        expect(@body).to.deep.equal this: 'is crazy'

      it 'should not log the error with sentry', ->
        expect(@client.captureError).to.not.have.been.called

      it 'should not parse the request', ->
        expect(@raven.parsers.parseRequest).to.not.have.been.called

    describe 'when a sendStatus 503 error response is made', ->
      beforeEach (done) ->
        @server
          .get '/blowup'
          .reply 503, STATUS_CODES[503]

        options = {
          @baseUrl,
          uri: '/blowup',
          json: true,
        }
        request.get options, (error, @response, @body) =>
          done error

      it 'should yield a 503', ->
        expect(@response.statusCode).to.equal 503

      it 'should yield the correct error response', ->
        expect(@body).to.equal STATUS_CODES[503]

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal STATUS_CODES[503]
        expect(@client.captureError.getCall(0).args[0].code).to.equal 503
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.called
