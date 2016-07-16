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
app.use(ravenExpress.requestHandler())
app.use(ravenExpress.errorHandler())
```

```coffee
# With DSN and release passed in
{ version } = require './package.json'
OctobluRaven = require 'octoblu-raven'

ravenExpress = new OctobluRaven({ dsn: 'the-sentry-dsn', release: version }).express()
app.use(ravenExpress.requestHandler())
app.use(ravenExpress.errorHandler())
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
