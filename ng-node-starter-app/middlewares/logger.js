'use strict';

const bunyan = require('bunyan');
const PrettyStream = require('bunyan-prettystream');

const prettyStdOut = new PrettyStream();
prettyStdOut.pipe(process.stdout);

const requestSerializer = req => ({
  query: (typeof req.query === 'function') ? req.query() : JSON.stringify(req.query),
  method: req.method,
  url: req.url,
  headers: req.headers,
  body: req.body,
});

const logger = bunyan.createLogger({
  name: 'ng-node-starter-app',
  serializers: {
    err: bunyan.stdSerializers.err,
    req: requestSerializer,
    res: bunyan.stdSerializers.res,
  },
  streams: [{
    level: 'debug',
    type: 'raw',
    stream: prettyStdOut,
  }, {
    type: 'rotating-file',
    path: 'logs/ng-node-starter-app.log',
    period: '1d',
  }],
});

function loggerMiddleware(level = 'info') {
  return (req, res, next) => {
    logger[level]({ req, res });
    next();
  };
}

module.exports = {
  loggerMiddleware,
  logger,
};
