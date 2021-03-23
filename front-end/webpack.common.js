const path = require('path')
const webpack = require('webpack')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TsconfigPathsPlugin = require('tsconfig-paths-webpack-plugin')

module.exports = {
  mode: 'development',
  entry: {
    app: {
      import: './src/js/app.ts',
      filename: '[name].js',
    },
    styles: {
      import: './src/stylesheets/main.src.css',
    },
  },
  output: {
    path: path.resolve(__dirname, '../_site/assets'),
  },
  module: {
    unsafeCache: true,
    rules: [
      {
        test: /\.ts$/,
        use: ['babel-loader', 'ts-loader'],
      },
      {
        test: /\.css$/,
        use: [
          { loader: MiniCssExtractPlugin.loader },
          { loader: 'css-loader', options: { importLoaders: 1 } },
          {
            loader: 'postcss-loader',
            options: {
              sourceMap: false,
              postcssOptions: {
                config: path.resolve(__dirname, 'postcss.config.js'),
              },
            },
          },
        ],
      },
    ],
  },
  resolve: {
    extensions: ['.css', '.ts', '.js'],
    plugins: [new TsconfigPathsPlugin()],
  },
  stats: {
    colors: true,
  },
  watchOptions: {
    ignored: /node_modules/,
    poll: true,
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'zepto-webpack',
    }),
    new MiniCssExtractPlugin({
      filename: 'dragonfly-[name].css',
    }),
  ],
}
