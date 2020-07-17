const path = require('path')
const webpack = require('webpack')

module.exports = {
  entry: path.resolve(__dirname, 'js/app.ts'),
  mode: 'production',
  output: {
    path: path.resolve(__dirname, '../content/scripts'),
    filename: 'app.bundle.js',
    chunkFilename: '[name].bundle.js',
  },
  module: {
    rules: [{
        test: /\.ts$/,
        loader: ['babel-loader', 'ts-loader'],
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'postcss-loader'],
      },
    ],
  },
  optimization: {
    splitChunks: {
      // include all types of chunks
      chunks: 'initial',
    },
  },
  stats: {
    colors: true,
  },
  devtool: 'source-map',
  resolve: {
    alias: {
      jquery: 'zepto',
    },
    extensions: ['.js', '.ts'],
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'zepto-webpack',
    }),
  ],
}
