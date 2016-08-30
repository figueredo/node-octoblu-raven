raven        = require 'raven'
OctobluRaven = require '../'

describe 'Express->meshbluAuthContext', ->
  beforeEach ->
    @dsn = 'https://xxx:xxx@app.getsentry.com/87213'
    @client = new raven.Client @dsn
    @client.setUserContext = sinon.spy()

  describe 'when the dsn exists', ->
    describe 'when the meshblu auth', ->
      beforeEach ->
        @sut = new OctobluRaven({ @dsn, release: 'v1.0.0' }, { @client }).express().meshbluAuthContext()
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
        @sut = new OctobluRaven({ @dsn, release: 'v1.0.0' }, { @client }).express().meshbluAuthContext()
        req = {}
        res =
          end: sinon.spy()
        @next = sinon.spy()
        @sut req, res, @next

      it 'should not set the meshblu auth context', ->
        expect(@client.setUserContext).to.not.have.been.called

      it 'should call next', ->
        expect(@next).to.have.been.called

