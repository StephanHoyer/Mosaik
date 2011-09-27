connect = require('connect')
Config = require('./configparser')

serverConfig = new Config()
server = null

module.exports.createServer = createServer = (config) ->
    server = connect.createServer()
    server.addConfig = addConfig
    server.compileConfig = compileConfig
    server.addConfig(config) if config
    server

addConfig = (config) ->
    serverConfig.merge(config)

compileConfig = () ->
    serverConfig.compile()
    server.use(connect.router((app) ->
        for routeObj in serverConfig.routes
            for route in routeObj.routes
                app.get(route, (req, res, next) ->
                    res.send = (content) -> res.end(content)
                    routeObj.dispatch(
                        req: req, 
                        res: res, 
                        done: () -> null, 
                        next: next
                    )
                )
    ))

###
server.use(connect.router((app) ->
    app.get('/', (req, res, next) ->
        body = 'Hello World'
        res.setHeader('Content-Length', body.length)
        res.end(body)
    )
    app.get('/:something', (req, res, next) ->
        body = req.params.something
        res.setHeader('Content-Length', body.length)
        res.end(body)
    )
))
###

