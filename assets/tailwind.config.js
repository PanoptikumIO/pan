const colors = require('tailwindcss/colors')

module.exports = {
  purge: {
    enabled: process.env.NODE_ENV === "production",
    content: [
      "../lib/**/templates/**/*.{leex,eex,ex}",
      "../lib/**/views/**/*.{ex,sface}",
      "../lib/**/live/**/*.{ex,sface}",
      "../lib/**/surface/**/*.{ex,sface}",
      "./js/**/*.js",  
    ],
    options: {
      whitelist: []
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    fontFamily: {
      sans: ['Ubuntu'],
      mono: ['Ubuntu\\ Mono'],
    },
    extend: {
      colors: {
        amber: colors.amber,
        blueGray: colors.blueGray,
        coolGray: colors.coolGray,
        cyan: colors.cyan,
        lightBlue: colors.lightBlue,
        lime: colors.lime,
        orange: colors.orange,
        rose: colors.rose,
        teal: colors.teal,
        violet: colors.violet,
      }
    },
  },
  variants: {
    extend: {
      backgroundColor: ['odd', 'even'],
    },
  },
}