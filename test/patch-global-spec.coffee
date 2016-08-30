raven             = require 'raven'
OctobluRaven      = require '../'

describe 'OctobluRaven->patchGlobal', ->
  beforeEach ->
    @dsn = 'https://xxx:xxx@app.getsentry.com/87213'
    @client = new raven.Client @dsn
    @client.patchGlobal = sinon.spy()

  describe 'when the dsn exists', ->
    beforeEach ->
      @sut = new OctobluRaven({ @dsn, release: 'v1.0.0', stayAlive: true }, { @client })

    describe 'when called', ->
      beforeEach ->
        @sut.patchGlobal()

      it 'should call the client.patchGlobal', ->
        expect(@client.patchGlobal).to.have.been.called

  describe 'when the dsn does not exist', ->
    beforeEach ->
      @sut = new OctobluRaven()

    describe 'when called', ->
      beforeEach ->
        @sut.patchGlobal()

      it 'should not call the client.patchGlobal', ->
        expect(@client.patchGlobal).to.have.not.been.called
