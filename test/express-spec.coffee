OctobluRaven = require '../'

describe 'Express', ->
  beforeEach ->
    @raven =
      middleware:
        express:
          requestHandler: sinon.spy()
          errorHandler: sinon.spy()

  describe 'when the dsn exists', ->
    describe 'when constructed with a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express()

      describe '->requestHandler', ->
        beforeEach ->
          @sut.requestHandler()

        it 'should call the raven middleware with the dsn', ->
          expect(@raven.middleware.express.requestHandler).to.have.been.calledWith 'the-dsn'

      describe '->errorHandler', ->
        beforeEach ->
          @sut.errorHandler()

        it 'should call the raven middleware with the dsn', ->
          expect(@raven.middleware.express.errorHandler).to.have.been.calledWith 'the-dsn'

    describe 'when constructed without a release', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn' }, { @raven }).express()

      describe '->requestHandler', ->
        beforeEach ->
          @sut.requestHandler()

        it 'should call the raven middleware with the dsn', ->
          expect(@raven.middleware.express.requestHandler).to.have.been.calledWith 'the-dsn'

      describe '->errorHandler', ->
        beforeEach ->
          @sut.errorHandler()

        it 'should call the raven middleware with the dsn', ->
          expect(@raven.middleware.express.errorHandler).to.have.been.calledWith 'the-dsn'

  describe 'when the dsn does not exist', ->
    beforeEach ->
      @sut = new OctobluRaven({ }, { @raven }).express()

    describe '->requestHandler', ->
      beforeEach ->
        @sut.requestHandler()

      it 'should call the raven middleware with the dsn', ->
        expect(@raven.middleware.express.requestHandler).to.not.have.been.called

    describe '->errorHandler', ->
      beforeEach ->
        @sut.errorHandler()

      it 'should call the raven middleware with the dsn', ->
        expect(@raven.middleware.express.errorHandler).to.not.have.been.called
