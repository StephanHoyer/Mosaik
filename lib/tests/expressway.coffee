should = require 'should'
ew = require '../expressway'

ew.should.respondTo('createServer')
ew.createServer().should.have.property('routes')
