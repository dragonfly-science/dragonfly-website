const webpack = require('webpack')
const path = require('path')
const ImageMinimizerPlugin = require("image-minimizer-webpack-plugin")

module.exports = {
  plugins: [
    new ImageMinimizerPlugin({
      test: /\.(jpe?g|png|gif)$/i,
      include: path.resolve(__dirname, '../_site/'),
      minimizerOptions: {
        // Lossless optimization with custom option
        // Feel free to experiment with options for better result for you
        plugins: [
          ["gifsicle", { interlaced: true }],
          ["jpegtran", { progressive: true }],
          ["optipng", { optimizationLevel: 5 }]
        ]
      },
    }),
  ],
};
