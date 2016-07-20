httpMocks    = require 'node-mocks-http'
OctobluRaven = require '../'

describe 'Express->sendError', ->
  beforeEach ->
    @client =
      captureError: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client
      parsers:
        parseRequest: sinon.stub().returns { some: 'thing' }

  beforeEach ->
    @consoleError = sinon.spy()
    @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express({ logFn: @consoleError }).sendError()

  describe 'called with a request response', ->
    beforeEach (done) ->
      @request = {}
      @response = httpMocks.createResponse()
      @sut @request, @response, done

    it 'should add the handleErrors method to the response object', ->
      expect(@response.sendError).to.be.a 'function'

    describe 'when is called with a generic error', ->
      beforeEach ->
        @response.sendError new Error 'random error'

      it 'should yield a 500 and the message', ->
        expect(@response.statusCode).to.equal 500
        expect(@response._getData()).to.deep.equal error: 'random error'

      it 'should log the error', ->
        expect(@consoleError).to.have.been.called

    describe 'when is called with a error with status', ->
      beforeEach ->
        error = new Error 'its a 422 error'
        error.code = 422
        @response.sendError error

      it 'should yield a 422 and the message', ->
        expect(@response.statusCode).to.equal 422
        expect(@response._getData()).to.deep.equal error: 'its a 422 error'

    describe 'when is called with a error with status', ->
      beforeEach ->
        error = new Error 'its a 502 error'
        error.code = 502
        @response.sendError error

      it 'should yield a 502 and the message', ->
        expect(@response.statusCode).to.equal 502
        expect(@response._getData()).to.deep.equal error: 'its a 502 error'

    describe 'when is called without an', ->
      it 'should throw an exception', ->
        expect(=> @response.sendError null).to.throw '[octoblu-raven] sendError called without an error'
