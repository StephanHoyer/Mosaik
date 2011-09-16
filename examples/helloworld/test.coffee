merge = require('../../lib/util').merge
should = require 'should'
should.throw = should.throws
server = null

module.exports = merge(module.exports,
    'App should have a server': () ->
        app = require('./app.js')
        app.should.have.property('server')
        server = app.server
    'Server should respond to base url': () ->
        should.response(server, {url: '/'}, {body: 'Hello World'})
    'Server should respond to specific url': () ->
        should.response(server, {url: '/foo'}, {body: 'foo'})
)        

