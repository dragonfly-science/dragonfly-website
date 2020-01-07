module.exports = {
    plugins: [
        require('precss')({}),
        require("postcss-import")({}),
        require('tailwindcss')('./tailwind.config.js'),
        require('autoprefixer')({}),
        require('postcss-preset-env')({ browsers: 'last 2 versions' }),
        require('postcss-easings')({}),
        require('cssnano')({}),
        require('@fullhuman/postcss-purgecss')({
            // Specify the paths to all of the template files in your project 
            content: [
                './content/templates/*.html',
                './_site/**/*.html',
            ],
            
            // Include any special characters you're using in this regular expression
            defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || [],

            whitelistPatterns: [
                /--disabled$/
            ],
            rejected: true
        })
    ]
}
