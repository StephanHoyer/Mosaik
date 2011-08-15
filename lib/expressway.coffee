express = require 'express'

module.exports.Server = class Server
    constructor: (args...) ->
        expressServer = express.createServer(args)
        expressServer.configure () ->
            expressServer.set('views', __dirname + '/views')
            expressServer.set('view engine', 'jade')
            expressServer.use(express.bodyParser())
            expressServer.use(express.methodOverride())
            expressServer.use(express.cookieParser())
            expressServer.use(express.session({ secret: 'your secret here' }))
            expressServer.use(expressServer.router)
            expressServer.use(express.static __dirname + '/public')

        expressServer.configure('development', () -> expressServer.use(express.errorHandler({ dumpExceptions: true, showStack: true })))

        expressServer.configure('production', () -> expressServer.use(express.errorHandler()))
        @expressServer = expressServer
    apps: () ->
        console.log('foo')
