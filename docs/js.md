# JavaScript

All JavaScript is written for ES6+ & compiled via [Webpack](https://webpack.js.org/),
parsed via [Babel](https://babeljs.io/).

## Webpack functions

The webpack configuration will be run whenever a css or js file changes. Webpack
will parse & compile JavaScript & CSS.

## Source

The source code lives inside the `/js` directory.
The main file is `app.js`.
When compiled, the output file is saved in `/scripts`

## Copying

Compiled CSS & JS are copied to the hakyll output directory `/_site`