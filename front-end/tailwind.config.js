const plugin = require('tailwindcss/plugin')

module.exports = {
  purge: {
    enabled: process.env.NODE_ENV === 'production',
    content: ['../_site/**/*.html'],
    options: {
      safelist: {
        greedy: [
          /tag-list__tag$/,
          /no-gutter-cell$/,
          /tile__citation$/,
          /filtering$/,
          /no-gutter-cell:hover$/,
          /^transition/,
          /^duration/,
          /^opacity/,
          /^bg-/,
        ],
      },
      rejected: true,
    },
  },
  theme: {
    fontFamily: {
      display: [
        'omnes-pro',
        '"Helvetica Neue"',
        'Helvetica',
        'Roboto',
        'Arial',
        'sans-serif',
      ],
      body: [
        'omnes-pro',
        '"Helvetica Neue"',
        'Helvetica',
        'Roboto',
        'Arial',
        'sans-serif',
      ],
    },
    colors: {
      beige: '#d2cec3',
      'cool-blue': '#43A1C9',
      'dark-jungle-green': '#1D1E21',
      'dark-peach': '#EB7A59',
      'faded-purple': '#A3649B',
      'faded-red': '#CF4547',
      grape: '#5B3456',
      'greeny-blue': '#50AD85',
      'greyish-brown': '#4a4a4a',
      'light-peach': '#E5DECC',
      'light-grey': '#D1D3D4',
      'pale-grey': '#F1F1F2',
      'pale-teal': '#9DC4A9',
      'slate-grey': '#565659',
      'very-light-pink': '#E7E7E7',
      'dark-grey': '#A7AAA9',
      white: '#FFFFFF',
      black: '#000000',
      transparent: 'transparent',
    },
    extend: {
      boxShadow: {
        '3xl': '0 0 40px 3px rgba(0,0,0,.3)',
      },
      fontSize: {
        '2/3xl': '1.6rem',
        '3/2xl': '2rem',
        '4/3xl': '2.4rem',
        '4/2xl': '2.5rem',
        '6/2xl': '4.5rem',
        '7xl': '5rem',
        '8xl': '6rem',
        '9xl': '7rem',
        '9/2xl': '7.5rem',
      },
      height: {
        16: '16rem',
        30: '30rem',
        44: '44rem',
      },
      lineHeight: {
        tighter: '1.2em',
        11: '2.6rem',
      },
      margin: {
        '12rem': '12rem',
        '-12rem': '-12rem',
        28: '7rem',
        '-28': '-7rem',
        '2/3': '66%',
        '1/2': '50%',
        '1/3': '33%',
        '3/4': '75%',
        '-2/3': '-66%',
        '-1/2': '-50%',
        '-1/3': '-33%',
        '-3/4': '75%',
        72: '18rem',
        80: '20rem',
        88: '22rem',
        96: '24rem',
        104: '28rem',
        '-72': '-18rem',
        '-80': '-20rem',
        '-88': '-22rem',
        '-96': '-24rem',
        '-104': '-28rem',
      },
      maxWidth: {
        '11rem': '11rem',
        '12rem': '12rem',
        '14rem': '14rem',
        '16rem': '16rem',
        '18rem': '18rem',
        '30rem': '30rem',
        '38rem': '38rem',
        '64rem': '64rem',
        '8/10': '80%',
        '3/4': '75%',
        '2/3': '66%',
        '5/3': '60%',
        '1/2': '50%',
        '5/2': '40%',
        '1/3': '33%',
        '1/4': '25%',
        '7xl': '102.5rem',
        '8xl': '120rem',
        100: '28rem',
        104: '30rem',
        sm: '640px',
        md: '768px',
        lg: '1024px',
        xl: '1280px',
        wd: '1920px',
      },
      maxHeight: {
        16: '16rem',
        28: '28rem',
        30: '30rem',
        42: '42rem',
        44: '44rem',
      },
      minHeight: {
        3: '3rem',
        16: '16rem',
        20: '20rem',
        24: '24rem',
        30: '30rem',
        36: '36rem',
        44: '44rem',
      },
      minWidth: {
        3: '3rem',
        12: '12rem',
        '12/5': '12.5rem',
        14: '14rem',
        16: '16rem',
        20: '20rem',
        24: '24rem',
        30: '30rem',
        36: '36rem',
        44: '44rem',
      },
      opacity: {
        10: '0.1',
        '025': '0.025',
        80: '0.8',
        90: '0.9',
      },
      rotate: {
        0: '0',
        135: '135deg',
      },
      transitionDuration: {
        250: '250ms',
      },
      transitionDelay: {
        0: '0ms',
      },
      transitionProperty: {
        all: 'all',
        bg: 'background-color',
        border: 'border-color',
        color: 'color',
        colors: ['color', 'background-color', 'border-color'],
        height: 'height',
        margin: 'margin',
        'max-height': 'max-height',
        none: 'none',
        opacity: 'opacity',
        padding: 'padding',
        top: 'top',
        transform: 'transform',
      },
      transitionTimingFunction: {
        'out-quart': 'easeOutQuart',
        'in-quart': 'easeInQuart',
      },
      width: {
        '1/5': '20%',
        72: '18rem',
        80: '20rem',
        88: '22rem',
        96: '24rem',
        100: '28rem',
        104: '30rem',
        108: '32rem',
        116: '36rem',
        120: '38rem',
      },
      zIndex: {
        1: '1',
      },
      spacing: {
        22: '5.5rem',
        28: '7rem',
        72: '18rem',
        80: '20rem',
        88: '22rem',
        96: '24rem',
        '12rem': '12rem',
        '14rem': '14rem',
        '16rem': '16rem',
        '18rem': '18rem',
        '30rem': '30rem',
        '38rem': '38rem',
        '64rem': '64rem',
        '8/10': '80%',
        '3/4': '75%',
        '2/3': '66%',
        '1/2': '50%',
        '1/3': '33%',
        '1/4': '25%',
        '7xl': '102.5rem',
        '8xl': '120rem',
      },
    },
  },
  plugins: [
    plugin(function ({ addUtilities }) {
      const newUtilities = {
        '.translate-3d': {
          transform: 'translate3d(0,0,0)',
        },
      }
      addUtilities(newUtilities, ['responsive', 'hover'])
    }),
    function ({ addVariant, e }) {
      addVariant('before', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`before${separator}${className}`)}:before`
        })
      })
    },
    function ({ addVariant, e }) {
      addVariant('after', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`after${separator}${className}`)}:after`
        })
      })
    },
    function ({ addVariant, e }) {
      addVariant('last-child', ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.${e(`last-child${separator}${className}`)}:last-child`
        })
      })
    },
  ],
}
