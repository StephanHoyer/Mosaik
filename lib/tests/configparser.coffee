merge = require('../util').merge
should = require 'should'
Config = require '../configparser'
should.throw = should.throws

config = new Config()

module.exports = merge(module.exports,
    'Config should have empty property config': () -> config.config.should.eql({})
    'Config should respond to validate': () -> config.should.respondTo('validate')
)

###
# Test syntactic validation
###

module.exports = merge(module.exports,
    'Empty object should be valid': () -> config.validate({}).should.be.ok

    'Random config key should throw error': () -> should.throw(() -> config.validate(foo: 'bar'))

    'Random block option should throw error': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    foo: []
        ))

    'Array of numbers as routes should throw error': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    routes: [1,2]
        ))

    'Number as route should throw error': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    routes: 123
        ))

    'Object as route should throw error': () ->
        should.throw(()-> config.validate(
            childs: 
                'route1':
                    routes: 
                        bar: 'foo'
        ))

    'Array of strings as routes should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    routes: [ 'index.php', '/index.html' ]
        ).should.be.ok
    'String as route should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    routes: '/index.html'
        ).should.be.ok

    'Regex as route should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    routes: /foo[0-9]/
        ).should.be.ok

    'Route type GET should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    types: 'GET'
        ).should.be.ok

    'Route type PUT should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    types: 'PUT'
        ).should.be.ok

    'Route type POST should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    types: 'POST'
        ).should.be.ok

    'Array of valid route types should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    types: ['GET', 'PUT', 'POST', 'DELETE']
        ).should.be.ok

    'Array of invalid route types should throw err': () ->
        should.throw((-> config.validate(
            childs: 
                'route1':
                    types: ['foo', 'PUT', 'POST', 'DELETE']
        )), 'Types should be on of GET, POST, PUT or DELETE')

    'Types in subblocks should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    childs: 
                        'block1':
                            types: ['GET', 'PUT', 'POST', 'DELETE']
        ).should.be.ok

    'Middleware with method of type number should throw error': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw1':
                            method: 123
        ))

    'Middleware with method of type function should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw2':
                            method: () -> null 
        ).should.be.ok

    'Multiple middlewares of type function should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw1':
                            method: () -> null 
                        'mw2':
                            method: () -> null 
        ).should.be.ok

    'Middleware should can have a dependency': () ->
        config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw2':
                            method: () -> null 
                            depends: 'mw1'
        ).should.be.ok

    'Middleware should can have multiple dependencies': () ->
        config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw2':
                            method: () -> null 
                            depends: ['a', 'b']
        ).should.be.ok

    'Middleware should can have followers': () ->
        config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw2':
                            method: () -> null 
                            prepares: ['a', 'b']
        ).should.be.ok

    'Middleware should have at least a method-node': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw2':
                            depends: 'mw1'
        ))

    'Depends should not be of type other than string or array of strings': () ->
        should.throw(()-> config.validate(
            childs: 
                'route1':
                    middlewares: 
                        'mw1':
                            depends: 123
                            method: () -> null
        ))

    'Route with property method should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    method: () -> null
        ).should.be.ok

    'Block method with type number should throw an error': () ->
        should.throw((-> config.validate(
            childs: 
                'route1':
                    method: 123
        )), '')

    'Block with property extends should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    extends: 'foo'
        ).should.be.ok

    'Block with property extends of type other then number should throw an error': () ->
        should.throw(() -> config.validate(
            childs: 
                'route1':
                    extends: 123
        ))

    'Block with property sortorder should be valid': () ->
        config.validate(
            childs: 
                'route1':
                    sortorder: 123 
        ).should.be.ok

    'Block with property sortorder should be valid': () ->
        should.throw((-> config.validate(
            childs: 
                'route1':
                    sortorder: 'foo'
        )), 'Block sortorder must be of type number')
)

###
# Test recursive merge
###

module.exports = merge(module.exports,
    'Merge of two empty objects should be empty object': () -> 
        config.recursiveMerge({},{}).should.eql({})

    'Merge of empty and non-empty object should be same as non-empty object itself': () -> 
        config.recursiveMerge({}, {a:1}).should.eql({a:1})

    'Merge of two identical objects should be one of the objects': () -> 
        config.recursiveMerge({a:1},{a:1}).should.eql({a:1})

    'Merge of two different objects with same properties should like the second one': () -> 
        config.recursiveMerge({a:1},{a:2}).should.eql({a:2})

    'Merge of two different objects with different properties should have both properties': () -> 
        config.recursiveMerge({a:1},{b:1}).should.eql({a:1,b:1})

    'Second object should alwas overwrite first, even if its more nestet': () -> 
        config.recursiveMerge({b:{a:2}},{b:{a:{c:3}}}).should.eql({b:{a:{c:3}}})

    'Merge of two different objects with different properties and nesting should have both properties': () -> 
        config.recursiveMerge({a:1},{b:{a:2}}).should.eql({a:1,b:{a:2}})

    'Also functions should be merged': () -> 
        func = ()->null
        should.deepEqual(config.recursiveMerge({}, {a:func}),{a:func})

    'Merge of two routes as strings should result in array of routes': () -> 
        config.recursiveMerge({routes: 'foo'}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})

    'Merge of routes as arrays and strings should result in array of routes': () -> 
        config.recursiveMerge({routes: ['foo']}, {routes: 'bar'}).should.eql({routes: ['foo', 'bar']})

    'Merge of routes as arrays should result in array of routes': () -> 
        config.recursiveMerge({routes: ['foo']}, {routes: ['bar']}).should.eql({routes: ['foo', 'bar']})

    'Resulting routes should not contain duplicates': () -> 
        config.recursiveMerge({routes: ['foo']}, {routes: ['foo']}).should.eql({routes: ['foo']})

    'Depends should behave like routes': () -> 
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
    'Merge with object as variable should also work': () ->
        obj = {}
        config.recursiveMerge(obj, {a:1})
        obj.should.eql({a:1})
)
###
# Test config merge
###

module.exports = merge(module.exports,
    'Merge to empty config should be identical to merged object': () ->
        config = new Config()
        config.merge(
            childs: 
                'route1':
                    sortorder: 123 
        ).config.should.eql(
            childs: 
                'route1':
                    sortorder: 123 
        )

    'Merge to existing config should be identical to merged object': () ->
        config = new Config()
        config.merge(
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
        )

    'Methods should also be merged': () ->
        config = new Config()
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
                    method: func
            })
)
###

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
    '__block:block1':
        method: func
        depends: ['bar', 'foo']
        prepares: 'route1'
    'baz':
        method: func
    'foo':
        method: func
        depends: ['baz','bar']
    'bar':
        method: func
}, config.config.childs.route1.middlewares, 'Middleware of second level should be merged to first level')


