const path = require('path')
const webpack = require('webpack')

module.exports = {
    entry: './content/js/app.js',
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
            }
        ]
    },
    stats: {
        colors: true
    },
    devtool: 'source-map'
};