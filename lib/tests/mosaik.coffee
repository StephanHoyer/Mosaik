merge = require('../util').merge
should = require('should')
should.throw = should.throws

mosaik = require('../mosaik')

module.exports = merge(module.exports,

    'Mosaik should respond to createServer': () ->
        mosaik.should.respondTo('createServer')

    'Server should respond to addConfig': () ->
        mosaik.createServer().should.respondTo('addConfig')

    'Add config containing a route should result in a requestable route': () ->
        server = mosaik.createServer()
        server.addConfig(
           layout:
               'helloWorld':
                    routes: '/'
                    middlewares:
                        'render': (t) -> 
                            t.res.send('Hello World')
                            t.done()
        )
        should.response(server, {url: '/'}, {body: 'Hello World'})
    ###
    ###
) 
