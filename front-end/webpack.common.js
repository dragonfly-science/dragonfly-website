const path = require('path')
const webpack = require('webpack')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TsconfigPathsPlugin = require('tsconfig-paths-webpack-plugin')
const { ESBuildMinifyPlugin } = require('esbuild-loader')

const isDev = process.env.NODE_ENV !== 'production'

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
  optimization: {
    minimize: !isDev,
    minimizer: !isDev
      ? [
          new ESBuildMinifyPlugin({
            target: 'es2015',
            css: true,
          }),
        ]
      : [],
  },
  module: {
    rules: [
      {
        test: /(\.ts)$/,
        exclude: /node_modules/,
        loader: 'esbuild-loader',
        options: {
          loader: 'ts',
          target: 'es2015',
        },
      },
      {
        test: /(\.css)$/,
        include: /node_modules/,
        use: [
          MiniCssExtractPlugin.loader,
          { loader: 'css-loader', options: { url: false } },
        ],
      },
      {
        test: /(\.css)$/,
        exclude: /node_modules/,
        use: [
          MiniCssExtractPlugin.loader,
          { loader: 'css-loader', options: { importLoaders: 1, url: false } },
          'postcss-loader',
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
