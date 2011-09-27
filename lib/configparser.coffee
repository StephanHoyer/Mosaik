arrayfy = require('./util').arrayfy
require('./util').ArrayUnique()


module.exports = class Config
    constructor: (@config={}) ->
        @routes = {} 
        @middlewares = {}
        #@__defineGetter__('routes', @getRoutes)

    merge: (config={}) ->
        @validate(config)
        @recursiveMerge(@config, config) 
        @

    compile: ->
        @walkRecursive()
        @validate(@config, 'semantic')
        @checkCircleMiddlewareDependencies()
        @

    recursiveMerge: (obj1, obj2) ->
        for key, value of obj2
            if key in ['routes', 'depends', 'prepares']
                obj1[key] = (arrayfy(obj1[key]).concat(arrayfy(value))).unique()
            else
                if obj1[key] and typeof obj1[key] is 'object' and typeof value is 'object'
                    obj1[key] = @recursiveMerge(obj1[key], value)
                else
                    obj1[key] = value
        obj1
    
    walkRecursive: (obj=@config, path=['ROOT']) ->
        if obj instanceof Object  
            for key, value of obj
                # collect routes
-               if path[0] is 'childs' and value.routes
-                    @routes[key] = arrayfy(value.routes)
                # add dispatch functions
                if path[0] in ['childs', 'layout'] 
                    value.dispatch = (t) -> t.res.send('foo World')
                    # collect routes
                    if value.routes
                        @routes[key] = arrayfy(value.routes)
                # collect middlewares
                if key is 'middlewares'
                    @collectMiddlewares(value)
                    continue
                @walkRecursive(value, [key].concat(path))
                # collect dependencies and save them to block
                @computeDependencies(value) if path[0] is 'childs'

    collectMiddlewares: (middlewares) ->
        for key, middleware of middlewares
            @middlewares[key] = {} unless @middlewares[key]
            @middlewares[key].method = middleware.method
            @middlewares[key].depends = arrayfy(@middlewares[key].depends)
                .concat(arrayfy(middleware.depends)).unique()
            @middlewares[key].prepares = arrayfy(@middlewares[key].prepares)
                .concat(arrayfy(middleware.prepares)).unique()

    computeDependencies: (obj) ->
        return unless obj instanceof Object
        obj.middlewares ?= {}
        if obj.childs
            for blockName, blockConfig of obj.childs when blockConfig.middlewares
                obj.middlewares = @recursiveMerge(obj.middlewares, blockConfig.middlewares)
        
    validate: (config={}, type='syntactic', name='ROOT') ->
        for key, value of config
            switch key
                when 'childs', 'layout'
                    for nodeName, config of config.childs
                        @validate(config, type, nodeName)
                when 'routes'
                    value = [value] if value not instanceof Array
                    for route in value 
                        @validateStringOrRegExp(
                            route,
                            "Block '#{name}': Route '#{route}' should be of \
                            type String or RegExp, but is of type '#{typeof route}'"
                        )
                when 'types'
                    value = [value] if value not instanceof Array
                    for type in value when type not in ['GET', 'POST', 'PUT', 'DELETE']
                        throw new Error("Block '#{name}': Type '#{type}' \
                            is not allowed, use one of 'GET', 'POST', 'PUT', 'DELETE'")
                when 'middlewares'
                    for middlewareName, middlewareConfig of value
                        @validateMiddleware(middlewareConfig, middlewareName, type, name) 
                when 'method'
                    @validateFunction(
                        value,
                        "Middleware '#{name}': Method '#{value}' should be of type \
                            Function but is of type '#{typeof value}'"
                    )
                when 'extends'
                    @validateString(
                        value,
                        "Block '#{name}': Block name to extend '#{value}' should be \
                            of type String but is of type '#{typeof value}'"
                    )
                when 'sortorder'
                    @validateNumber(
                        value,
                        "Block '#{name}': Block sortorder '#{value}' should be of type \
                            Number but is of type '#{typeof value}'"
                    )
                else
                    throw new Error("Block '#{name}': Unknown router key '#{key}'")
        @

    validateMiddleware: (config={}, middlewareName, type, blockName) ->
        return if typeof config is 'function'
        throw new Error("Middleware '#{middlewareName}': No method defined") if not config.method
        for key, value of config
            switch key
                when 'method'
                    @validateFunction(
                        value,
                        "Middleware '#{middlewareName}': Method '#{value}' should be of \
                            type Function but is of type '#{typeof value}'"
                    ) 
                when 'depends', 'prepares'
                    for dependency in arrayfy(value)
                        @validateString(
                            dependency, 
                            "Middleware '#{middlewareName}': \
                                #{value is 'depends' ? 'Dependency' : 'Follower'} \
                                '#{dependency}' should be of type String but is of \
                                type '#{typeof dependency}'"
                        )
                        throw new Error("Middleware '#{middlewareName}': Middleware can't \
                            be selfdepending") if middlewareName is dependency
                        if type is 'semantic' and not @middlewares[dependency]
                            throw new Error("Middleware '#{middlewareName}': Dependency \
                                '#{dependency}' has no implementation") 
                else 
                    throw new Error("Middleware '#{middlewareName}': Unknown config key '#{key}'")

    checkCircleMiddlewareDependencies: (middlewareName, chain=[]) ->
        unless middlewareName
            @checkCircleMiddlewareDependencies(middleware) for middleware of @middlewares
            return

        chain.push(middlewareName)
        for dependency in @middlewares[middlewareName].depends
            if dependency in chain
                chain.push(dependency)
                chainString = chain.join(' -> ')
                throw new Error("Middleware: Circle dependency detected: (#{chainString})") 
            @checkCircleMiddlewareDependencies(dependency, chain)
                
    attachDispatcher: (block) ->
        block.dispatch = @getDispatchFunction(block)

    completeDependencyArrays: (block) ->
        for name, func of block.middlewares
            func.method = func if typeof func is 'function'
            func.depends = arrayfy(func.depends)
            func.prepares = arrayfy(func.prepares)
            for dependency in func.depends
                dependency = block.middlewares[dependency]
                dependency.prepares = arrayfy(dependency.prepares)
                dependency.prepares.push(name) if name not in dependency.prepares
            for follower in func.prepares
                follower = block[follower]
                follower.depends = arrayfy(follower.depends)
                follower.depends.push(name) if name not in follower.depends
        block

    getDispatchFunction: (block) ->
        @completeDependencyArrays(block)
        __dispatchInit = {prepares: []}
        getDispatchFunc = (action) ->
            return (t) -> 
                if action.prepares
                    for name in action.prepares
                        follower = block.middlewares[name]
                        follower.isReady(t) if follower.isReady
                else
                    __dispatchFinish.isReady(t)
        getIsReadyFunc = (action) ->
            action.countDone = 0
            return (t) ->
                action.countDone++
                if action.countDone is action.depends.length
                    if action.method
                        action.method(t, () -> action.dispatch(t)) 
                    else
                        action.dispatch(t)
        for name, action of block.middlewares
            unless action.depends?.length 
                __dispatchInit.prepares.push(name)
                action.depends = ['__dispatchInit']
            action.isReady = getIsReadyFunc(action)
            action.dispatch = getDispatchFunc(action)
        block.__dispatchInit = __dispatchInit
        getDispatchFunc(__dispatchInit) 

    validateNumber: (value, message) ->
        throw new Error(message) if typeof value isnt 'number'
    
    validateString: (value, message) ->
        throw new Error(message) if typeof value isnt 'string'

    validateStringOrRegExp: (value, message) ->
        throw new Error(message) if typeof value isnt 'string' and value not instanceof RegExp

    validateFunction: (value, message) ->
        throw new Error(message) if typeof value isnt 'function'
