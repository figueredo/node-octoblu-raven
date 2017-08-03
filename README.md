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

**Optional:**

```javascript
const options = {
  dsn: 'the-sentry-dsn',
  logFn: function() {}
}
new OctobluRaven(options)
```

**NOTE:** if no DSN is provided, it default to normal behavior and will not log with sentry

### Express

**!IMPORTANT:** As of v4.0.0 use the new expressBundle method since it makes everyones life easier.

There is no longer a need for including express-send-error since that is included in the bundle.

For use with express apps.

```coffee
express      = require 'express'
OctobluRaven = require 'octoblu-raven'
app          = express()

new OctobluRaven().handleExpress({ app })
```

### Catch Uncaught Exceptions

Use at the root the project, typically in `./command.js`. This can be used independently or with the use of the Express Middleware.

```coffee
OctobluRaven = require 'octoblu-raven'
new OctobluRaven().patchGlobal()
```

### Report Error, or Message

Use this to manually report an error or message to Sentry.

```coffee
OctobluRaven = require 'octoblu-raven'
octobluRaven = new OctobluRaven()
octobluRaven.reportError(new Error('oh no'))
```
