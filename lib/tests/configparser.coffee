should = require 'should'
parser = require '../configparser'
should.throw = should.throws

parser.should.respondTo('Config')
config = new parser.Config()
config.config.should.eql({})
config.should.respondTo('validate')

###
# Test syntactic validation
###

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

should.throw((-> config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw1':
                    method: 123
)), 'Method of type number must not be possible')

config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw2':
                    method: (req, res) -> null 
).should.be.ok

config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw1':
                    method: (req, res) -> null 
                'mw2':
                    method: (req, res) -> null 
).should.be.ok

config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw2':
                    method: (req, res) -> null 
                    depends: ['a', 'b']
).should.be.ok

config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw2':
                    method: (req, res) -> null 
                    depends: 'mv1'
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw2':
                    depends: 'mv1'
)), 'Middleware has to have at least a method-node')

should.throw((-> config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw1':
                    depends: 123
                    method: () -> null
)), 'depends must not be of type other than string or array of strings')

config.validate(
    childs: 
        'route1':
            method: () -> null
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            method: 123
)), 'Block method must not be of type other than function')

config.validate(
    childs: 
        'route1':
            extends: 'foo'
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            extends: 123
)), 'Block extends must be of type string')

config.validate(
    childs: 
        'route1':
            sortorder: 123 
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            sortorder: 'foo'
)), 'Block sortorder must be of type number')

###
# Test recursive merge
###

config.recursiveMerge({},{}).should.eql({})
config.recursiveMerge({}, {a:1}).should.eql({a:1})
config.recursiveMerge({a:1},{a:1}).should.eql({a:1})
config.recursiveMerge({a:1},{a:2}).should.eql({a:2})
config.recursiveMerge({a:1},{b:1}).should.eql({a:1,b:1})
config.recursiveMerge({a:1},{b:{a:2}}).should.eql({a:1,b:{a:2}})
config.recursiveMerge({b:{a:2}},{b:{a:{c:3}}}).should.eql({b:{a:{c:3}}})
config.recursiveMerge({}, {a:()->null}).toString().should.eql({a:()->null}.toString())
config.should.respondTo('arrayfy')
config.arrayfy('foo').should.eql(['foo'])
config.arrayfy(undefined).should.eql([])
config.arrayfy(123).should.eql([123])
config.arrayfy([123]).should.eql([123])
config.recursiveMerge({routes: 'foo'}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})
config.recursiveMerge({routes: ['foo']}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})
config.recursiveMerge({routes: ['foo']}, {routes: ['bar']}).should.eql({routes: ['foo', 'bar']})
obj = {}
config.recursiveMerge(obj, {a:1})
obj.should.eql({a:1})

###
# Test config merge
###

config.merge(
    childs: 
        'route1':
            sortorder: 123 
).config.should.eql(
    childs: 
        'route1':
            sortorder: 123 
)

config.merge(
    childs: 
        'route1':
            sortorder: 1234
).config.should.eql(
    childs: 
        'route1':
            sortorder: 1234
, )

config.merge(
    childs: 
        'route1':
            method: () -> null
).config.toString().should.eql({
    childs: 
        'route1':
            sortorder: 1234
            method: () -> null
    }.toString()
, 'Method should be merged to existing node')

###
# test routes tracking
###

config = new parser.Config()

config.merge(
    childs: 
        'block1':
            routes: 'foo'
)
console.log(config)
config.routes.should.eql([
    'block1': 'foo'
])

        



###
# test sematic validation
###

config = new parser.Config()

config.merge(
    childs: 
        'route1':
            middlewares:
                'mv1':
                    method: () -> null
).should.be.ok

should.throw((-> config.merge(
    childs: 
        'route1':
            middlewares:
                'mv1':
                    method: () -> null
                    depends: 'mv1'
)), 'Middleware can\'t be selfdepending')

