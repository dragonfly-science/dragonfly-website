module.exports = {
  theme: {
    fontFamily: {
      display: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
      body: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
    },
    extend: {
      colors: {
        'cool-blue': '#43A1C9',
        'dark-peach': '#EB7A59',
        'slate-grey': '#565659',
        'faded-red': '#CF4547',
        'greeny-blue': '#50AD85',
        'grape': '#5B3456',
        'light-peach': '#E5DECC',
        'pale-teal': '#9DC4A9',
        'very-light-pink': '#E7E7E7',
        'pale-grey': '#F1F1F2',
        'faded-purple': '#A3649B'
      },
      fontSize: {
        '6/2xl': '4.5rem',
        '7xl': '5rem',
        '8xl': '6rem',
        '9xl': '7rem',
        '9/2xl': '7.5rem',
      },
      maxWidth: {
        '12rem': '12rem',
        '3/4': '75%',
        '1/2': '50%',
        '1/3': '33%',
        '1/4': '25%',
      },
      minHeight: {
        '20': '20rem',
        '24': '24rem',
        '30': '30rem',
        '36': '36rem',
      }
    }
  },
  variants: {},
  plugins: [
    function({ addUtilities }) {
      const newUtilities = {
        '.rotate-90': {
          transform: 'rotate(90deg)',
        },
        '.rotate-180': {
          transform: 'rotate(180deg)',
        },
      }

      addUtilities(newUtilities)
    },
    function({ addVariant, e }) {
      addVariant('before', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`before${separator}${className}`)}:before`
        })
      })
    },
    function({ addVariant, e }) {
      addVariant('after', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`after${separator}${className}`)}:after`
        })
      })
    },
    function({ addVariant, e }) {
      addVariant('last-child', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`last-child${separator}${className}`)}:last-child`
        })
      })
    },
  ]
}
