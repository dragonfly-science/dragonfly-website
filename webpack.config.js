const path = require('path')
const webpack = require('webpack')

module.exports = {
    entry: path.resolve(__dirname, 'content/js/app.ts'),
    mode: 'development',
    output: {
        path: path.resolve(__dirname, 'content/scripts'),
        filename: 'app.bundle.js'
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
            },
            {
                test: /\.tsx?/,
                loader: ['ts-loader'],
            },
            {
                test: /\.css$/,
                use: [ 'style-loader', 'postcss-loader' ]
            },
            {
                test: require.resolve('zepto'),
                use: 'imports-loader?this=>window',
            }
        ]
    },
    stats: {
        colors: true
    },
    devtool: 'source-map',
    resolve: {
        alias: {
            jquery: 'zepto',
        },
        extensions: ['.js', '.ts'],
    }
};