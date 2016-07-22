OctobluRaven = require '../'

describe 'Express->meshbluAuthContext', ->
  beforeEach ->
    @client =
      setUserContext: sinon.spy()

    @raven =
      Client: sinon.stub().returns @client

  describe 'when the dsn exists', ->
    describe 'when the meshblu auth', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express().meshbluAuthContext()
        req =
          meshbluAuth:
            uuid: 'hello'
        @next = sinon.spy()
        res =
          end: sinon.spy()
        @sut req, res, @next

      it 'should set the meshblu auth context', ->
        expect(@client.setUserContext).to.have.been.calledWith { uuid: 'hello' }

      it 'should call next', ->
        expect(@next).to.have.been.called

    describe 'when with no meshblu auth', ->
      beforeEach ->
        @sut = new OctobluRaven({ dsn: 'the-dsn', release: 'v1.0.0' }, { @raven }).express().meshbluAuthContext()
        req = {}
        res =
          end: sinon.spy()
        @next = sinon.spy()
        @sut req, res, @next

      it 'should not set the meshblu auth context', ->
        expect(@client.setUserContext).to.not.have.been.called

      it 'should call next', ->
        expect(@next).to.have.been.called

    describe 'when with no DSN', ->
      beforeEach ->
        @sut = new OctobluRaven({ }, { @raven }).express().meshbluAuthContext()
        req =
          meshbluAuth:
            uuid: 'hello'
        @next = sinon.spy()
        @sut req, null, @next

      it 'should not set the meshblu auth context', ->
        expect(@client.setUserContext).to.not.have.been.called

      it 'should call next', ->
        expect(@next).to.have.been.called
