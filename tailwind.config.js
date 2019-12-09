module.exports = {
  theme: {
    fontFamily: {
      display: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
      body: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
    },
    extend: {
      colors: {
        'beige': '#d2cec3',
        'cool-blue': '#43A1C9',
        'dark-peach': '#EB7A59',
        'faded-purple': '#A3649B',
        'faded-red': '#CF4547',
        'grape': '#5B3456',
        'greeny-blue': '#50AD85',
        'greyish-brown': '#4a4a4a',
        'light-peach': '#E5DECC',
        'light-grey': '#D1D3D4',
        'pale-grey': '#F1F1F2',
        'pale-teal': '#9DC4A9',
        'slate-grey': '#565659',
        'very-light-pink': '#E7E7E7',
      },
      fontSize: {
        '4/2xl': '2.5rem',
        '6/2xl': '4.5rem',
        '7xl': '5rem',
        '8xl': '6rem',
        '9xl': '7rem',
        '9/2xl': '7.5rem',
      },
      margin: {
        '28': '7rem',
        '-28': '-7rem',
        '2/3': '66%',
        '1/2': '50%',
        '1/3': '33%',
        '-2/3': '-66%',
        '-1/2': '-50%',
        '-1/3': '-33%',
        '72': '18rem',
        '80': '20rem',
        '88': '22rem',
        '96': '24rem',
        '-72': '-18rem',
        '-80': '-20rem',
        '-88': '-22rem',
        '-96': '-24rem',
      },
      maxWidth: {
        '12rem': '12rem',
        '3/4': '75%',
        '1/2': '50%',
        '1/3': '33%',
        '1/4': '25%',
        '7xl': '102.5rem',
        '8xl': '120rem',
      },
      minHeight: {
        '20': '20rem',
        '24': '24rem',
        '30': '30rem',
        '36': '36rem',
      },
      screens: {
        'wd': '104rem'
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
        '.-rotate-45': {
          transform: 'rotate(-45deg)',
        },
        '.rotate-45': {
          transform: 'rotate(45deg)',
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
