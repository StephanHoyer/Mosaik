arrayfy = require('./util').arrayfy
require('./util').ArrayUnique()


module.exports = class Config
    constructor: (@config={}) ->
        @routes = {} 
        @actions = {}
        #@__defineGetter__('routes', @getRoutes)

    merge: (config={}) ->
        @validate(config)
        @recursiveMerge(@config, config) 
        @

    compile: ->
        @walkRecursive()
        @validate(@config, 'semantic')
        @checkCircleActionDependencies()
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
                if path[0] is 'blocks' and value.routes
                    @routes[key] = arrayfy(value.routes)
                
                # add dispatch functions
                if path[0] in ['blocks', 'layout'] 
                    # collect routes
                    if value.routes
                        @routes[key] = arrayfy(value.routes)
                # collect actions
                if key is 'actions'
                    @collectActions(value)
                    continue
                @walkRecursive(value, [key].concat(path))
                # collect dependencies and save them to block
                @computeDependencies(value) if path[0] is 'blocks'

    collectActions: (actions) ->
        for key, action of actions
            @actions[key] = {} unless @actions[key]
            @actions[key].method = action.method
            @actions[key].depends = arrayfy(@actions[key].depends)
                .concat(arrayfy(action.depends)).unique()
            @actions[key].prepares = arrayfy(@actions[key].prepares)
                .concat(arrayfy(action.prepares)).unique()

    computeDependencies: (obj) ->
        return unless obj instanceof Object
        obj.actions ?= {}
        if obj.blocks
            for blockName, blockConfig of obj.blocks when blockConfig.actions
                obj.actions = @recursiveMerge(obj.actions, blockConfig.actions)
        
    validate: (config={}, type='syntactic', name='ROOT') ->
        for key, value of config
            switch key
                when 'blocks', 'layout'
                    for nodeName, config of config.blocks
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
                when 'actions'
                    for actionName, actionConfig of value
                        @validateAction(actionConfig, actionName, type, name) 
                when 'method'
                    @validateFunction(
                        value,
                        "Action '#{name}': Method '#{value}' should be of type \
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

    validateAction: (config={}, actionName, type, blockName) ->
        return if typeof config is 'function'
        throw new Error("Action '#{actionName}': No method defined") if not config.method
        for key, value of config
            switch key
                when 'method'
                    @validateFunction(
                        value,
                        "Action '#{actionName}': Method '#{value}' should be of \
                            type Function but is of type '#{typeof value}'"
                    ) 
                when 'depends', 'prepares'
                    for dependency in arrayfy(value)
                        @validateString(
                            dependency, 
                            "Action '#{actionName}': \
                                #{value is 'depends' ? 'Dependency' : 'Follower'} \
                                '#{dependency}' should be of type String but is of \
                                type '#{typeof dependency}'"
                        )
                        throw new Error("Action '#{actionName}': action can't \
                            be selfdepending") if actionName is dependency
                        if type is 'semantic' and not @actions[dependency]
                            throw new Error("Action '#{actionName}': Dependency \
                                '#{dependency}' has no implementation") 
                else 
                    throw new Error("Action '#{actionName}': Unknown config key '#{key}'")

    checkCircleActionDependencies: (actionName, chain=[]) ->
        unless actionName
            @checkCircleActionDependencies(action) for action of @actions
            return

        chain.push(actionName)
        for dependency in @actions[actionName].depends
            if dependency in chain
                chain.push(dependency)
                chainString = chain.join(' -> ')
                throw new Error("Action: Circle dependency detected: (#{chainString})") 
            @checkCircleActionDependencies(dependency, chain)
                
    attachDispatcher: (block) ->
        block.dispatch = @getDispatchFunction(block)

    completeDependencyArrays: (block) ->
        for name, func of block.actions
            func.method = func if typeof func is 'function'
            func.depends = arrayfy(func.depends)
            func.prepares = arrayfy(func.prepares)
            for dependency in func.depends
                dependency = block.actions[dependency]
                continue unless dependency
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
            return (req) -> 
                if action.prepares
                    for name in action.prepares
                        follower = block.actions[name]
                        follower.isReady(req) if follower.isReady
                else
                    __dispatchFinish.isReady(t)
        getIsReadyFunc = (action) ->
            action.countDone = 0
            return (req) ->
                action.countDone++
                if action.countDone is action.depends.length
                    if action.method
                        action.method(req, block, {done: () -> action.dispatch(req)})
                    else
                        action.dispatch(req)
        for name, action of block.actions
            unless action.depends?.length and action.depends is ['__dispatchInit']
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
