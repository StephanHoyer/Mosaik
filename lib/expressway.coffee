express = require 'express'
module.exports = express

exports.createServer = module.exports.createServer (args...) ->
    app = express.createServer(args...)
    app.configure () ->
        app.set 'views', __dirname + '/views'
        app.set 'view engine', 'jade'
        app.use express.bodyParser
        app.use express.methodOverride
        app.use express.cookieParser
        app.use express.session { secret: 'your secret here' }
        app.use app.router()
        app.use express.static __dirname + '/public'

    app.configure 'development', () -> app.use express.errorHandler { dumpExceptions: true, showStack: true }

    app.configure 'production', () -> app.use express.errorHandler()

