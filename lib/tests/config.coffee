should = require('should')
Config = require('../config')
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
            blocks: 
                'route1':
                    foo: []
        ))

    'Array of numbers as routes should throw error': () ->
        should.throw(() -> config.validate(
            blocks: 
                'route1':
                    routes: [1,2]
        ))

    'Number as route should throw error': () ->
        should.throw(() -> config.validate(
            blocks: 
                'route1':
                    routes: 123
        ))

    'Object as route should throw error': () ->
        should.throw(()-> config.validate(
            blocks: 
                'route1':
                    routes: 
                        bar: 'foo'
        ))

    'Array of strings as routes should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    routes: [ 'index.php', '/index.html' ]
        ).should.be.ok
    'String as route should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    routes: '/index.html'
        ).should.be.ok

    'Regex as route should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    routes: /foo[0-9]/
        ).should.be.ok

    'Route type GET should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    types: 'GET'
        ).should.be.ok

    'Route type PUT should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    types: 'PUT'
        ).should.be.ok

    'Route type POST should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    types: 'POST'
        ).should.be.ok

    'Array of valid route types should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    types: ['GET', 'PUT', 'POST', 'DELETE']
        ).should.be.ok

    'Array of invalid route types should throw err': () ->
        should.throw((-> config.validate(
            blocks: 
                'route1':
                    types: ['foo', 'PUT', 'POST', 'DELETE']
        )), 'Types should be on of GET, POST, PUT or DELETE')

    'Types in subblocks should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    blocks: 
                        'block1':
                            types: ['GET', 'PUT', 'POST', 'DELETE']
        ).should.be.ok

    'Action with method of type number should throw error': () ->
        should.throw(() -> config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw1':
                            method: 123
        ))

    'Action of type function should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2': () -> null 
        ).should.be.ok

    'Action with method of type function should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2':
                            method: () -> null 
        ).should.be.ok

    'Multiple actions with method of type function should be valid': () ->
        config.validate(
            blocks:
                'route1':
                    actions: 
                        'mw1':
                            method: () -> null 
                        'mw2':
                            method: () -> null 
        ).should.be.ok

    'Action should can have a dependency': () ->
        config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2':
                            method: () -> null 
                            depends: 'mw1'
        ).should.be.ok

    'Action should can have multiple dependencies': () ->
        config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2':
                            method: () -> null 
                            depends: ['a', 'b']
        ).should.be.ok

    'Action should can have followers': () ->
        config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2':
                            method: () -> null 
                            prepares: ['a', 'b']
        ).should.be.ok

    'Action should have at least a method-node': () ->
        should.throw(() -> config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw2':
                            depends: 'mw1'
        ))

    'Depends should not be of type other than string or array of strings': () ->
        should.throw(()-> config.validate(
            blocks: 
                'route1':
                    actions: 
                        'mw1':
                            depends: 123
                            method: () -> null
        ))

    'Route with property method should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    method: () -> null
        ).should.be.ok

    'Block method with type number should throw an error': () ->
        should.throw((-> config.validate(
            blocks: 
                'route1':
                    method: 123
        )), '')

    'Block with property extends should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    extends: 'foo'
        ).should.be.ok

    'Block with property extends of type other then number should throw an error': () ->
        should.throw(() -> config.validate(
            blocks: 
                'route1':
                    extends: 123
        ))

    'Block with property sortorder should be valid': () ->
        config.validate(
            blocks: 
                'route1':
                    sortorder: 123 
        ).should.be.ok

    'Block with property sortorder should be valid': () ->
        should.throw((-> config.validate(
            blocks: 
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
            blocks: 
                'route1':
                    sortorder: 123 
        ).config.should.eql(
            blocks: 
                'route1':
                    sortorder: 123 
        )

    'Merge to existing config should be identical to merged object': () ->
        config = new Config()
        config.merge(
            blocks: 
                'route1':
                    sortorder: 123 
        )

        config.merge(
            blocks: 
                'route1':
                    sortorder: 1234
        ).config.should.eql(
            blocks: 
                'route1':
                    sortorder: 1234
        )

    'Methods should also be merged': () ->
        config = new Config()
        func = () -> null
        should.deepEqual(
            config.merge(
                blocks: 
                    'route1':
                        method: func 
            ).config, 
            {
            blocks: 
                'route1':
                    method: func
            })
)
###
# test attachment of dispatch function
###

# func is a function that is returning the 
# same random number every time called
func = (() -> 
    rand = Math.random()
    return (req, block, action) -> 
        t.result = block.data + rand
        action.done();
)()


module.exports = merge(module.exports,
    'Call of attachDispatcher should generate a method dispatch': () ->
        config = new Config()
        config.merge(
            blocks: 
                'route1':
                    actions: 
                        "render": 
                            method: func 
        )
        config.should.respondTo('attachDispatcher')
        config.attachDispatcher(config.config.blocks.route1)
        config.config.blocks.route1.should.respondTo('dispatch')
        t1 = {data: 'foo'} 
        t2 = {data: 'foo'} # @todo clone t1
        config.config.blocks.route1.dispatch(t1)
        func(t2, ()->null)
        t1.result.should.eql(t2.result)
    ###
    'Short syntax of defining action should also be possible': () ->
        config = new Config()
        config.merge(
            blocks: 
                'route1':
                    actions: 
                        "render": func 
        )
        config.attachDispatcher(config.config.blocks.route1)
        config.config.blocks.route1.dispatch('foo').should.eql(func('foo'))

    'Dependencies in middles should be integrated in the dispatch method': () ->
        config = new Config()
        config.merge(
            blocks: 
                'route1':
                    actions: 
                        "render": 
                            method: func 
        )
        config.attachDispatcher(config.config.blocks.route1)
        config.config.blocks.route1.dispatch('foo').should.eql(func('foo'))
    ###
)





###
###
# test routes tracking
###

config = new Config()

config.merge(
    blocks: 
        'block1':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo'],
    'Merge to empty config should generate one route'
)
config.merge(
    blocks: 
        'block1':
            routes: 'foo'
).compile()

config.routes.should.eql(
    'block1': ['foo'],
    'Merge same route again should change nothing'
)

config.merge(
    blocks: 
        'block2':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo'],
    'Merge of new block should add new routes entry'
)

config.merge(
    blocks: 
        'block2':
            routes: 'bar'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo', 'bar'],
    'Merge of new route should add new entry to existing route entry'
)

###
# test action tracking
###

config = new Config()
func = () -> null
config.merge(
    blocks: 
        'block1':
            actions:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends:
                        'bar'
).compile()
should.deepEqual(
    config.actions,
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
    blocks: 
        'block1':
            actions:
                'foo':
                    method: func
                    depends: 'baz'
                'baz':
                    method: func
).compile()

should.deepEqual(
    config.actions,
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
    'Add new dependency to action should also be added to action collection'
)

###
# test routes tracking
###

config.merge(
    blocks: 
        'block1':
            routes: 'foo'
).compile()

config.routes.should.eql(
    'block1': ['foo']
    , 'Merge same route again should change nothing'
)

config.merge(
    blocks: 
        'block2':
            routes: 'foo'
).compile()
config.routes.should.eql(
    'block1': ['foo']
    'block2': ['foo']
    , 'Merge of new block should add new routes entry'
)

config.merge(
    blocks: 
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
    blocks: 
        'route1':
            actions:
                'mw1':
                    method: () -> null
                'mw2':
                    method: () -> null
                    depends: 'mw1'
).compile().should.be.ok

should.throw((-> config.merge(
    blocks: 
        'route1':
            actions:
                'mw1':
                    method: () -> null
                    depends: 'mw1'
).compile()), 'Action can\'t be selfdepending')

should.throw((-> config.merge(
    blocks: 
        'route1':
            actions:
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
    blocks: 
        'route1':
            actions:
                'mw2':
                    method: () -> null
                    depends: 'mw1'
                'mw1':
                    method: () -> null
                    depends: 'mw2'
).compile()), 'Circle dependency detected (2 steps)')

should.throw((-> config.merge(
    blocks: 
        'route1':
            actions:
                'mw1':
                    method: () -> null
                    depends: 'mw2'
).compile()), 'Action can\'t depend on unexisting action')

###
# test dependency computation
###
config.should.respondTo('computeDependencies')

func = -> null
config = new Config()

config.merge(
    blocks: 
        'route1':
            method: func
)

config.compile()

should.deepEqual({
    blocks: 
        'route1':
            method: func
            actions: {}
}, config.config, 'No action should result in empty action object')

config = new Config()

config.merge(
    blocks: 
        'route1':
            method: func
            actions:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
).compile()

should.deepEqual({
    blocks: 
        'route1':
            method: func
            actions:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
}, config.config, 'Only on level of blocks should not change anything')

config = new Config()

config.merge(
    blocks: 
        'route1':
            method: func
            blocks: 
                'block1':
                    method: func
                    actions:
                        'bar':
                            method: func
                        'foo':
                            method: func
                            depends: 'bar'
).compile()

should.deepEqual({
    blocks: 
        'route1':
            method: func
            blocks: 
                'block1':
                    method: func
                    actions:
                        'bar':
                            method: func
                        'foo':
                            method: func
                            depends: 'bar'
            actions:
                'bar':
                    method: func
                'foo':
                    method: func
                    depends: 'bar'
}, config.config, 'Action of second level should also be pulled to first level')

config = new Config()
config.merge(
    blocks: 
        'route1':
            method: func
            actions:
                'baz':
                    method: func
                'foo':
                    method: func
                    depends: 'baz'
            blocks: 
                'block1':
                    method: func
                    actions:
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
}, config.config.blocks.route1.actions, 'Action of second level should be merged to first level')


