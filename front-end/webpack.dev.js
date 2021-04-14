const path = require('path')
const { merge } = require('webpack-merge')
const common = require('./webpack.common.js')

module.exports = (env) => {
  return merge(common, {
    mode: 'development',
    watchOptions: {
      ignored: /node_modules/,
    },
  })
}
