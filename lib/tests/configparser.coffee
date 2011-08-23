should = require 'should'
Config = require '../configparser'
should.throw = should.throws

config = new Config()
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
                    depends: 'mw1'
).should.be.ok

should.throw((-> config.validate(
    childs: 
        'route1':
            middlewares: 
                'mw2':
                    depends: 'mw1'
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
func = ()->null
should.deepEqual(config.recursiveMerge({}, {a:func}),{a:func})
config.recursiveMerge({routes: 'foo'}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})
config.recursiveMerge({routes: ['foo']}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})
config.recursiveMerge({routes: ['foo']}, {routes: ['bar']}).should.eql({routes: ['foo', 'bar']})
config.recursiveMerge({routes: ['foo']}, {routes: ['foo']}).should.eql({routes: ['foo']})
should.deepEqual(
    config.recursiveMerge(
        {
            dependsTest: 
                depends: ['foo']
        },{
            dependsTest:
                depends: 'bar'
        }
    ),
    dependsTest:
        depends: ['foo', 'bar']
)
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

func = () -> null
should.deepEqual(
    config.merge(
        childs: 
            'route1':
                method: func 
    ).config, 
    {
    childs: 
        'route1':
            sortorder: 1234
            method: func
    },
    'Method should be merged to existing node'
)

###
# test routes tracking
###

config = new Config()

config.merge(
    childs: 
        'block1':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo'],
    'Merge to empty config should generate one route'
)
config.merge(
    childs: 
        'block1':
            routes: 'foo'
).compile()

config.routes.should.eql(
    'block1': ['foo'],
    'Merge same route again should change nothing'
)

config.merge(
    childs: 
        'block2':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo'],
    'Merge of new block should add new routes entry'
)

config.merge(
    childs: 
        'block2':
            routes: 'bar'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo', 'bar'],
    'Merge of new route should add new entry to existing route entry'
)

###
# test middleware tracking
###

config = new Config()
func = () -> null
config.merge(
    childs: 
        'block1':
            middlewares:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends:
                        'bar'
).compile()
should.deepEqual(
    config.middlewares,
    'bar': 
        method: func
        depends: []
    'foo': 
        method: func
        depends: ['bar']
    ,
    'Merge to empty config should generate one middelware'
)

config.merge(
    childs: 
        'block1':
            middlewares:
                'foo':
                    method: func
                    depends: 'baz'
                'baz':
                    method: func
).compile()

should.deepEqual(
    config.middlewares,
    'bar': 
        method: func
        depends: []
    'foo': 
        method: func
        depends: ['bar', 'baz']
    'baz': 
        method: func
        depends: []
    ,
    'Add new dependency to middleware should also be added to middleware collection'
)

###
# test routes tracking
###

config.merge(
    childs: 
        'block1':
            routes: 'foo'
).compile()

config.routes.should.eql(
    'block1': ['foo']
    , 'Merge same route again should change nothing'
)

config.merge(
    childs: 
        'block2':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo']
    , 'Merge of new block should add new routes entry'
)

config.merge(
    childs: 
        'block2':
            routes: 'bar'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo', 'bar']
, 'Merge of new route should add new entry to existing route entry')

###
# test sematic validation
###

config = new Config()

config.merge(
    childs: 
        'route1':
            middlewares:
                'mw1':
                    method: () -> null
                'mw2':
                    method: () -> null
                    depends: 'mw1'
).compile().should.be.ok

should.throw((-> config.merge(
    childs: 
        'route1':
            middlewares:
                'mw1':
                    method: () -> null
                    depends: 'mw1'
).compile()), 'Middleware can\'t be selfdepending')

should.throw((-> config.merge(
    childs: 
        'route1':
            middlewares:
                'mw3':
                    method: () -> null
                    depends: 'mw2'
                'mw2':
                    method: () -> null
                    depends: 'mw1'
                'mw1':
                    method: () -> null
                    depends: 'mw3'
).compile()), 'Circle dependency detected (3 steps)')

should.throw((-> config.merge(
    childs: 
        'route1':
            middlewares:
                'mw2':
                    method: () -> null
                    depends: 'mw1'
                'mw1':
                    method: () -> null
                    depends: 'mw2'
).compile()), 'Circle dependency detected (2 steps)')

should.throw((-> config.merge(
    childs: 
        'route1':
            middlewares:
                'mw1':
                    method: () -> null
                    depends: 'mw2'
).compile()), 'Middleware can\'t depend on unexisting middleware')

###
# test dependency computation
###
config.should.respondTo('computeDependencies')

func = -> null
config = new Config()

config.merge(
    childs: 
        'route1':
            method: func
)

config.compile()

should.deepEqual({
    childs: 
        'route1':
            method: func
            middlewares: {}
}, config.config, 'No middleware should result in empty middleware object')

config = new Config()

config.merge(
    childs: 
        'route1':
            method: func
            middlewares:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
).compile()

should.deepEqual({
    childs: 
        'route1':
            method: func
            middlewares:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
}, config.config, 'Only on level of blocks should not change anything')

config = new Config()

config.merge(
    childs: 
        'route1':
            method: func
            childs: 
                'block1':
                    method: func
                    middlewares:
                        'bar':
                            method: func
                        'foo':
                            method: func
                            depends: 'bar'
).compile()

should.deepEqual({
    childs: 
        'route1':
            method: func
            childs: 
                'block1':
                    method: func
                    middlewares:
                        'bar':
                            method: func
                        'foo':
                            method: func
                            depends: 'bar'
            middlewares:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
}, config.config, 'Middleware of second level should also be pulled to first level')

config = new Config()
config.merge(
    childs: 
        'route1':
            method: func
            middlewares:
                'baz':
                    method: func
                'foo':
                    method: func
                    depends: 'baz'
            childs: 
                'block1':
                    method: func
                    middlewares:
                        'foo':
                            method: func
                            depends: 'bar'
                        'bar':
                            method: func
).compile()

should.deepEqual({
    childs: 
        'route1':
            method: func
            middlewares:
                'baz':
                    method: func
                'foo':
                    method: func
                    depends: ['baz','bar']
                'bar':
                    method: func
            childs: 
                'block1':
                    method: func
                    middlewares:
                        'foo':
                            method: func
                            depends: 'bar'
                        'bar':
                            method: func
}, config.config, 'Middleware of second level should be merged to first level')


