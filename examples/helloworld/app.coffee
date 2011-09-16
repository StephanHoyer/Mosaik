connect = require('connect')

module.exports.server = server = connect.createServer()

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

server.listen(3000)


