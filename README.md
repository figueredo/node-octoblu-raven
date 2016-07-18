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

### Express

For use with express apps

```coffee
# With DSN and release as environment
# env SENTRY_DSN='the-sentry-dsn'
# env SENTRY_RELEASE='git-tag'
OctobluRaven = require 'octoblu-raven'

ravenExpress = new OctobluRaven().express()
# Ensures asynchronous exceptions are routed to the errorHandler. This
# should be the **first** item listed in middleware.
app.use(ravenExpress.requestHandler())
# Error handler. This should be the last item listed in middleware, but
# before any other error handlers.
app.use(ravenExpress.errorHandler())
# Expose response.sendError, which handles responding to the user with errors.
# Only 500 errors and above are sent to Sentry
# See express-send-error for more details
app.use(ravenExpress.sendError())
```

```coffee
# With DSN and release passed in
{ version } = require './package.json'
OctobluRaven = require 'octoblu-raven'

ravenExpress = new OctobluRaven({ dsn: 'the-sentry-dsn', release: version }).express()
# Ensures asynchronous exceptions are routed to the errorHandler. This
# should be the **first** item listed in middleware.
app.use(ravenExpress.requestHandler())
# Error handler. This should be the last item listed in middleware, but
# before any other error handlers.
app.use(ravenExpress.errorHandler())
# Expose response.sendError, which handles responding to the user with errors.
# Only 500 errors and above are sent to Sentry
# See express-send-error for more details
app.use(ravenExpress.sendError())
```

### Worker

For use with workers

```coffee
# With DSN and release as environment
# env SENTRY_DSN='the-sentry-dsn'
# env SENTRY_RELEASE='git-tag'
OctobluRaven = require 'octoblu-raven'

ravenWorker = new OctobluRaven().worker()
ravenWorker.handleErrors()
```

```coffee
# With DSN and release passed in
{ version } = require './package.json'
OctobluRaven = require 'octoblu-raven'

ravenWorker = new OctobluRaven({ dsn: 'the-sentry-dsn', release: version }).worker()
ravenWorker.handleErrors()
```
