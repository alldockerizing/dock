'use strict';

module.exports = {
  apps: [
    {
      name: 'ng-node-starter-app',
      script: './app.js',
      node_args: ['--inspect=9090'],
      watch: true,
    },
  ],
};
