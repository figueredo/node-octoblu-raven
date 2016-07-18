httpMocks    = require 'node-mocks-http'
OctobluRaven = require '../'

describe 'Express->sendError', ->
  beforeEach ->
    @client =
      captureException: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client

  beforeEach ->
    @consoleError = sinon.spy()
    @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express().sendError { logFn: @consoleError }

  describe 'called with a request response', ->
    beforeEach (done) ->
      @request = null
      @response = httpMocks.createResponse()
      @sut @request, @response, done

    it 'should add the sendError method to the response object', ->
      expect(@response.sendError).to.be.a 'function'

    describe 'when the sendError function is called with a generic error', ->
      beforeEach ->
        @response.sendError new Error 'random error'

      it 'should yield a 500 and the message', ->
        expect(@response.statusCode).to.equal 500
        expect(@response._getData()).to.deep.equal error: 'random error'

      it 'should log the error', ->
        expect(@consoleError).to.have.been.called

      it 'should log the error with sentry', ->
        expect(@client.captureException).to.have.been.called

    describe 'when the sendError function is called with a error with status', ->
      beforeEach ->
        error = new Error 'its a 422 error'
        error.code = 422
        @response.sendError error

      it 'should yield a 422 and the message', ->
        expect(@response.statusCode).to.equal 422
        expect(@response._getData()).to.deep.equal error: 'its a 422 error'

      it 'should log the error', ->
        expect(@consoleError).to.have.been.called

      it 'should not log the error with sentry since it is not a 500', ->
        expect(@client.captureException).to.not.have.been.called

    describe 'when the sendError function is called without an', ->
      it 'should throw an exception', ->
        expect(=> @response.sendError null).to.throw '[octoblu-raven-send-error] sendError called without an error'
