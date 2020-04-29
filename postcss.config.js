module.exports = (context) => ({
    plugins: [
        require('postcss-preset-env')({ browsers: 'last 2 versions' }),
        require('postcss-reporter')({}),
        require('postcss-import')({}),
        require('postcss-easings')({}),
        require('postcss-nested')({}),
        require('tailwindcss')('./tailwind.config.js'),
        require('autoprefixer')({}),
        context.env === 'production' ? require('cssnano')({}) : false,
        context.env === 'production' ? require('@fullhuman/postcss-purgecss')({
            // Specify the paths to all of the template files in your project 
            rejected: true,
            content: [
                './content/templates/*.html',
                './content/pages/*.html',
                './_site/**/*.html',
            ],
            
            // Include any special characters you're using in this regular expression
            defaultExtractor: content => content.match(/[\w-?\/:]+(?<!:)/g) || [],

            whitelistPatterns: [
                /--disabled$/,
                /body-content.*/,
                /whitespace-*/,
                /loaded$/,
                /transition-*/,
                /duration-*/,
                /ease-*/,
                /dragonfly-*/
            ],
        }) : false
    ]
})