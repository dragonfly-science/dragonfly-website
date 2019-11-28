module.exports = {
    plugins: [
        require('precss'),
        require("postcss-import"),
        require('tailwindcss')('./tailwind.config.js'),
        require('autoprefixer'),
        require('postcss-preset-env')({ browsers: 'last 2 versions' })
    ]
}
