# node-octoblu-raven

Raven Error handling for Octoblu Services and Workers.

[![Build Status](https://travis-ci.org/octoblu/node-octoblu-raven.svg)](https://travis-ci.org/octoblu/)
[![npm version](https://badge.fury.io/js/octoblu-raven.svg)](http://badge.fury.io/js/octoblu-raven)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

## Installation

```bash
npm install --save octoblu-raven
```

## Usage

### Configuration Environment

**Recommended:**

`env SENTRY_DSN='the-sentry-dsn'`

`env SENTRY_RELEASE='git-version'`

`env SENTRY_NAME='some-app-name'` *optional*

**Optional:**

```coffee
overrideOptions = {
  dsn: 'the-sentry-dsn',
  release: 'project-version',
  name: 'some-app-name',
}
new OctobluRaven(overrideOptions)
```

**NOTE:** if no DSN is provided, it default to normal behavior and will not log with sentry

### Express

For use with express apps.

```coffee
OctobluRaven = require 'octoblu-raven'
ravenExpress = new OctobluRaven().express()

# Set the UUID of auth'd device as the user context for Sentry
# NOTE: Place after meshbluAuth middleware
app.use(ravenExpress.meshbluAuthContext())

# Capture error requests with a status code of 500 or greater
# This is fully compatible with the use of `express-send-error`
# NOTE: User octobluRaven.patchGlobal() to capture uncaught exceptions
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

### Catch Uncaught Exceptions

Use at the root the project, typically in `./command.js`. This can be used independently or with the use of the Express Middleware.

```coffee
OctobluRaven = require 'octoblu-raven'
octobluRaven = new OctobluRaven()
octobluRaven.patchGlobal()
```

### Report Error, or Message

Use this to manually report an error or message to Sentry.

```coffee
OctobluRaven = require 'octoblu-raven'
octobluRaven = new OctobluRaven()
octobluRaven.reportError(new Error('oh no'))
# or it will take a string
octobluRaven.reportError('oh no')
```

### Set User Context

This can be used to set the user context.

```coffee
OctobluRaven = require 'octoblu-raven'
octobluRaven = new OctobluRaven()
octobluRaven.setUserContext({
  uuid: 'some-uuid',
  email: 'some-email',
})
```
