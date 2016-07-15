{ Worker } = require '../'

describe 'Worker', ->
  beforeEach ->
    @client =
      patchGlobal: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client

  describe 'when the dsn exists', ->
    describe 'when constructed with a release', ->
      beforeEach ->
        @sut = new Worker { dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }

      describe '->handleErrors', ->
        beforeEach ->
          @sut.handleErrors()

        it 'should create a client', ->
          expect(@raven.Client).to.have.been.calledWith 'the-dsn', {
            release: 'v1.0.0'
          }

        it 'should call the client.patchGlobal', ->
          expect(@client.patchGlobal).to.have.been.called

    describe 'when constructed without a release', ->
      beforeEach ->
        @sut = new Worker { dsn: 'the-dsn' }, { @raven }

      describe '->handleErrors', ->
        beforeEach ->
          @sut.handleErrors()

        it 'should create a client', ->
          expect(@raven.Client).to.have.been.calledWith 'the-dsn', {}

        it 'should call the client.patchGlobal', ->
          expect(@client.patchGlobal).to.have.been.called

  describe 'when the dsn does not exist', ->
    beforeEach ->
      @sut = new Worker { }, { @raven }

    describe '->handleErrors', ->
      beforeEach ->
        @sut.handleErrors()

      it 'should not create a client', ->
        expect(@raven.Client).to.have.not.been.called

      it 'should call the client.patchGlobal', ->
        expect(@client.patchGlobal).to.have.not.been.called
