/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable @typescript-eslint/explicit-function-return-type */
module.exports = ({ env }) => {
  return {
    plugins: [
      require('postcss-preset-env')({
        browsers: 'last 2 versions',
      }),
      require('postcss-import')(),
      require('postcss-easings')(),
      require('postcss-nested')(),
      require('tailwindcss')('./tailwind.config.js'),
      require('autoprefixer')(),
      // env === 'production' ? require('cssnano')({
      //   preset: 'default'
      // }) : false,
    ],
  }
}
