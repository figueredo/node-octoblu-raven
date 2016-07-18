OctobluRaven = require '../'

describe 'Express->requestHandler', ->
  beforeEach ->
    @raven =
      Client: sinon.stub().returns {}
      middleware:
        express:
          requestHandler: sinon.spy()

  describe 'when the dsn exists', ->
    describe 'when constructed with a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express().requestHandler()

      it 'should call the raven middleware with the dsn', ->
        expect(@raven.middleware.express.requestHandler).to.have.been.calledWith 'the-dsn'

    describe 'when constructed without a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn' }, { @raven }).express().requestHandler()

      it 'should call the raven middleware with the dsn', ->
        expect(@raven.middleware.express.requestHandler).to.have.been.calledWith 'the-dsn'

  describe 'when the dsn does not exist', ->
    beforeEach ->
      @sut = new OctobluRaven({ }, { @raven }).express().requestHandler()

    it 'should call the raven middleware with the dsn', ->
      expect(@raven.middleware.express.requestHandler).to.not.have.been.called
