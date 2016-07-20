_            = require 'lodash'
httpMocks    = require 'node-mocks-http'
OctobluRaven = require '../'

describe 'Express->handleErrors', ->
  beforeEach ->
    @client =
      captureError: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client
      parsers:
        parseRequest: sinon.stub().returns { some: 'thing' }

  beforeEach ->
    @consoleError = sinon.spy()
    @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express({ logFn: @consoleError }).handleErrors()

  describe 'called with a error middleware', ->
    describe 'when a error response is made', ->
      beforeEach (done) ->
        @request = {}
        @response = httpMocks.createResponse({
          eventEmitter: require('events').EventEmitter
        })
        @next = sinon.spy()
        routerHandler = (request, response, next) =>
          @sut request, response, next
          @response.status(500).send error: 'random error'

        @response.once 'end', () =>
          _.delay done, 100

        routerHandler @request, @response, @next

      it 'should yield a 500 and the message', ->
        expect(@response.statusCode).to.equal 500
        expect(@response._getData()).to.deep.equal error: 'random error'

      it 'should log the error with sentry', ->
        expect(@client.captureError.getCall(0).args[0].message).to.equal 'random error'
        expect(@client.captureError.getCall(0).args[0].code).to.equal 500
        expect(@client.captureError.getCall(0).args[1]).to.deep.equal { some: 'thing' }

      it 'should parse the request', ->
        expect(@raven.parsers.parseRequest).to.have.been.calledWith @request

    describe 'when is called with a non-500 error status', ->
      beforeEach (done) ->
        @request = {}
        @response = httpMocks.createResponse({
          eventEmitter: require('events').EventEmitter
        })
        @next = sinon.spy()
        @response.once 'end', =>
          _.delay done, 100

        routerHandler = (request, response, next) =>
          @sut request, response, next
          @response.status(422).send error: 'its a 422 error'

        routerHandler @request, @response, @next

      it 'should yield a 422 and the message', ->
        expect(@response.statusCode).to.equal 422
        expect(@response._getData()).to.deep.equal error: 'its a 422 error'

      it 'should not log the error with sentry since it is not a 500', ->
        expect(@client.captureError).to.not.have.been.called

    describe 'when is called with an error status', ->
      beforeEach (done) ->
        @request = {}
        @response = httpMocks.createResponse({
          eventEmitter: require('events').EventEmitter
        })
        @next = sinon.spy()
        @response.once 'end', =>
          _.delay done, 100

        routerHandler = (request, response, next) =>
          @sut request, response, next
          @response.status(502).send error: 'its a 502 error'

        routerHandler @request, @response, @next

      it 'should yield a 502 and the message', ->
        expect(@response.statusCode).to.equal 502
        expect(@response._getData()).to.deep.equal error: 'its a 502 error'

      it 'should not log the error with sentry since it is a 500 level', ->
        expect(@client.captureError).to.have.been.called

  describe 'called with a successful request', ->
    beforeEach (done) ->
      @request = {}
      @response = httpMocks.createResponse()
      @sut @request, @response, done

    it 'should yield a 200 and the message', ->
      expect(@response.statusCode).to.equal 200
