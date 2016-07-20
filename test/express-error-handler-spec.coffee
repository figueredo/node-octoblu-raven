OctobluRaven = require '../'

describe 'Express->errorHandler', ->
  beforeEach ->
    @client = {the: 'client'}
    @raven =
      Client: sinon.stub().returns @client
      middleware:
        express:
          errorHandler: sinon.spy()

  describe 'when the dsn exists', ->
    describe 'when constructed with a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express().errorHandler()

      it 'should call the raven middleware with the client', ->
        expect(@raven.middleware.express.errorHandler).to.have.been.calledWith @client

    describe 'when constructed without a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn' }, { @raven }).express().errorHandler()

      it 'should call the raven middleware with the client', ->
        expect(@raven.middleware.express.errorHandler).to.have.been.calledWith @client

  describe 'when the dsn does not exist', ->
    beforeEach ->
      @sut = new OctobluRaven({ }, { @raven }).express().errorHandler()

    it 'should not call the raven middleware', ->
      expect(@raven.middleware.express.errorHandler).to.not.have.been.called
