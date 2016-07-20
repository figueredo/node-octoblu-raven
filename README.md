# node-octoblu-raven
Raven Error handling for Octoblu Services and workers.

[![Build Status](https://travis-ci.org/octoblu/.svg?branch=master)](https://travis-ci.org/octoblu/)
[![Code Climate](https://codeclimate.com/github/octoblu//badges/gpa.svg)](https://codeclimate.com/github/octoblu/)
[![Test Coverage](https://codeclimate.com/github/octoblu//badges/coverage.svg)](https://codeclimate.com/github/octoblu/)
[![npm version](https://badge.fury.io/js/.svg)](http://badge.fury.io/js/)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

## Installation

```bash
npm install --save octoblu-raven
```

## Usage

### Configuration Environment

`env SENTRY_DSN='the-sentry-dsn'`
`env SENTRY_RELEASE='project-version'`

- Optionally you can pass them into the constructor

```coffee
new OctobluRaven({ dsn: 'the-sentry-dsn', release: 'project-version' })
```

**NOTE:** if no DSN is provided, it default to normal behavior and will not log with sentry

### Express

For use with express apps.

```coffee
OctobluRaven = require 'octoblu-raven'
ravenExpress = new OctobluRaven().express()
# Use request.meshbluAuth.uuid to set on the raven user context
# Place after meshbluAuth middleware
app.use(ravenExpress.meshbluAuthContext())
# Use this expose response.sendError()
app.use(ravenExpress.sendError())
# Capture and Send Errors
# Place after all middleware
# Will capture error requests (statusCode >= 500)
# **NOTE:** Add octobluRaven.worker().handleErrors() to capture uncaught exceptions
# This will report the following cases:
#   app.get '/blowup/500', (req, res, next) =>
#     res.status(500).send error: 'oh no'
#   app.get '/blowup/sendError', (req, res, next) =>
#     error = new Error 'oh no'
#     error.code = 502
#     res.sendError error
#   app.get '/blowup/uncaught', (req, res, next) =>
#     throw new Error 'oh no'
app.use(ravenExpress.handleErrors())
```

### Worker

For use in the root of node projects. This will report uncaught exceptions.

```coffee
OctobluRaven = require 'octoblu-raven'
ravenWorker = new OctobluRaven().worker()
ravenWorker.handleErrors()
```
