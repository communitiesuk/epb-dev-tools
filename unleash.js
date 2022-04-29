require('dotenv').config()

const unleash = require('unleash-server')
const myCustomAdminAuth = require('./unleash-auth-hook')

unleash
  .start({
    databaseUrl: process.env.DATABASE_URL,
    port: '8080',
    secret: process.env.TOGGLES_SECRET,
    authentication: {
      type: 'custom',
      customAuthHandler: myCustomAdminAuth
    }
  })
  .then(unleash => {
    console.log(
      'Started'
    )
  })
