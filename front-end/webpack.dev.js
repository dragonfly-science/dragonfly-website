const path = require('path')
const { merge } = require('webpack-merge')
const common = require('./webpack.common.js')

module.exports = (env) => {
  const { cacheLocation } = env
  return merge(common, {
    mode: 'development',
    cache: {
      type: 'filesystem',
      cacheLocation:
        cacheLocation !== undefined
          ? cacheLocation
          : path.resolve(__dirname, 'node_modules/.cache/webpack'),
    },
  })
}
