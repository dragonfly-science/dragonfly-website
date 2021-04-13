const path = require('path')
const { merge } = require('webpack-merge')
const common = require('./webpack.common.js')

module.exports = (env) => {
  const { cacheLocation } = env
  return merge(common, {
    mode: 'development',
  })
}
