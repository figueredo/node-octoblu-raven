express       = require 'express'
enableDestroy = require 'server-destroy'

class ExpressServer
  constructor: ({ octobluRaven }) ->
    @app = express()
    octobluRaven.handleExpress { @app }

  use: (middleware) =>
    @app.use middleware

  route: (method, route, fn) =>
    @app[method] route, fn

  start: (callback) =>
    @_routes()
    @server = @app.listen undefined, callback
    enableDestroy @server
    return @server

  destroy: (callback) =>
    @server.destroy callback

  baseUrl: =>
    return "http://localhost:#{@server.address().port}"

  _routes: =>
    @app.get '/throw/error', =>
      throw new Error 'hello'

    @app.get '/uncaught/error', =>
      unknownfunc 'called with'

    @app.get '/blowup', (req, res) =>
      res.sendStatus 500

    @app.get '/blowup/504', (req, res) =>
      res.sendStatus 504

    @app.get '/blowup/422', (req, res) =>
      res.sendStatus 422

    @app.get '/blowup/sendUserError', (req, res) =>
      error = new Error 'oh no user error'
      error.code = 429
      res.sendError error

    @app.get '/blowup/sendError', (req, res) =>
      error = new Error 'oh no error'
      error.code = 500
      res.sendError error

    @app.get '/blowup/sendError/no-code', (req, res) =>
      error = new Error 'oh no error'
      res.sendError error

    @app.get '/blowup/sendError/error-object', (req, res) =>
      error = new Error { oh: no: 'error' }
      error.code = 500
      res.sendError error

    @app.get '/blowup/sendError/string', (req, res) =>
      res.sendError 'oh no error'

    @app.get '/blowup/sendError/object', (req, res) =>
      res.sendError oh: no: 'error'

    @app.get '/blowup/error', (req, res) =>
      res.status(500).send error: "oh no error"

    @app.get '/blowup/object', (req, res) =>
      res.status(500).send oh: no: 'error'

    @app.get '/success', (req, res) =>
      res.sendStatus(200)

    @app.get '/success/string', (req, res) =>
      res.status(200).send 'success'

    @app.get '/success/object', (req, res) =>
      res.status(200).send success: true

module.exports = ExpressServer
