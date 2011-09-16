mosaik = require('../../lib/mosaik')

module.exports.server = server = mosaik.createServer()

server.addConfig(
   layout:
       'helloWorld':
            routes: '/'
            middlewares:
                'render': (transport) -> transport.res.send('Hello World')
       'something':
            routes: '/:something'
            middlewares:
                'render': (transport) -> transport.res.send(transport.req.params.something)
)

###
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
###
server.listen(3000)


