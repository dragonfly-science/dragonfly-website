module.exports = {
  theme: {
    fontFamily: {
      display: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
      body: ['omnes-pro', '"Helvetica Neue"', 'Helvetica', 'Roboto', 'Arial', 'sans-serif'],
    },
    extend: {
      boxShadow: {
        '3xl': '20px 30px 40px 3px rgba(0,0,0,.3)'
      },
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
        '2/3xl': '1.6rem',
        '3/2xl': '2rem',
        '4/2xl': '2.5rem',
        '6/2xl': '4.5rem',
        '7xl': '5rem',
        '8xl': '6rem',
        '9xl': '7rem',
        '9/2xl': '7.5rem',
      },
      margin: {
        '12rem': '12rem',
        '-12rem': '-12rem',
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
        '104': '28rem',
        '-72': '-18rem',
        '-80': '-20rem',
        '-88': '-22rem',
        '-96': '-24rem',
        '-104': '-28rem',
      },
      maxWidth: {
        '12rem': '12rem',
        '14rem': '14rem',
        '16rem': '16rem',
        '38rem': '38rem',
        '8/10': '80%',
        '3/4': '75%',
        '2/3': '66%',
        '1/2': '50%',
        '1/3': '33%',
        '1/4': '25%',
        '7xl': '102.5rem',
        '8xl': '120rem',
      },
      minHeight: {
        '3': '3rem',
        '20': '20rem',
        '24': '24rem',
        '30': '30rem',
        '36': '36rem',
      },
      opacity: {
        '10': '0.1',
        '025': '0.025',
      },
      screens: {
        'wd': '104rem'
      },
      transitionProperty: {
        'all': 'all',
        'bg': 'background-color',
        'border': 'border-color',
        'color': 'color',
        'colors': ['color', 'background-color', 'border-color'],
        'height': 'height',
        'margin': 'margin',
        'max-height': 'max-height',
        'none': 'none',
        'opacity': 'opacity',
        'padding': 'padding',
        'top': 'top',
        'transform': 'transform',
      },
      transitionTimingFunction: {
        'default': 'ease',
        'linear': 'linear',
        'ease': 'ease',
        'ease-in': 'ease-in',
        'ease-out': 'ease-out',
        'ease-in-out': 'ease-in-out',
        'ease-in-quart': 'easeInQuart',
        'ease-out-quart': 'easeOutQuart',
        'ease-out-expo': 'easeOutExpo',
        'ease-in-back': 'easeInBack',
        'ease-out-back': 'easeOutBack',
        'ease-in-out-back': 'easeInOutBack',
      },
    },
  },
  variants: {},
  plugins: [
    function({ addUtilities }) {
      const newUtilities = {
        '.rotate-0': {
          transform: 'rotate(0deg)',
        },
        '.rotate-90': {
          transform: 'rotate(90deg)',
        },
        '.-rotate-90': {
          transform: 'rotate(-90deg)',
        },
        '.-rotate-45': {
          transform: 'rotate(-45deg)',
        },
        '.rotate-45': {
          transform: 'rotate(45deg)',
        },
        '.rotate-135': {
          transform: 'rotate(135deg)',
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
    require('tailwindcss-transitions')(),
  ]
}
