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
                test: /\.tsx?/,
                loader: ['babel-loader'],
            },
            {
                test: /\.css$/,
                use: [ 'style-loader', 'postcss-loader' ]
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
    },
    plugins: [
        new webpack.ProvidePlugin({
            $: 'zepto-webpack'
        }),
    ]
};