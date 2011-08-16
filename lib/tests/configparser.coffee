should = require 'should'
parser = require '../configparser'
should.throw = should.throws

parser.should.respondTo('Config')
config = new parser.Config()
config.should.eql(
    config: {}
)
config.should.respondTo('validate')
config.validate({}).should.be.ok
should.throw(-> config.validate(foo: 'bar'))

should.throw((-> config.validate(
    childs: 
        'route1':
            foo: []
)), 'Block option can\'t be anything, e. G. foo.')

should.throw((-> config.validate(
    childs: 
        'route1':
            routes: [1,2]
)), 'Routes can\'t be a array of numbers')

should.throw((-> config.validate(
    childs: 
        'route1':
            routes: 123
)), 'Route can\'t be a number')

should.throw((-> config.validate(
    childs: 
        'route1':
            routes: 
                bar: 'foo'
)), 'Routes must not be objects')

config.validate(
    childs: 
        'route1':
            routes: [ 'index.php', '/index.html' ]
).should.be.ok

config.validate(
    childs: 
        'route1':
            routes: '/index.html'
).should.be.ok
###
# @TODO validator for regex routes
config.validate(
    childs: 
        'route1':
            routes: /foo[0-9]/
).should.be.ok
###
config.validate(
    childs: 
        'route1':
            types: 'GET'
).should.be.ok

config.validate(
    childs: 
        'route1':
            types: 'PUT'
).should.be.ok

config.validate(
    childs: 
        'route1':
            types: 'POST'
).should.be.ok

config.validate(
    childs: 
        'route1':
            types: ['GET', 'PUT', 'POST', 'DELETE']
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            types: ['foo', 'PUT', 'POST', 'DELETE']
)), 'Types should be on of GET, POST, PUT or DELETE')

config.validate(
    childs: 
        'route1':
            childs: 
                'block1':
                    types: ['GET', 'PUT', 'POST', 'DELETE']
).should.be.ok

process.exit(1)
###
config.should.respondTo('merge')
config.merge({}).should.eql(config)

    config:
        childs: 
            'route1':
                routes: []
)
