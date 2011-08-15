should = require 'should'
ew = require '../expressway'

ew.should.respondTo('Server')
server = new ew.Server()

server.should.respondTo('apps')
server.apps(
    'foo',
    'bar'
)

