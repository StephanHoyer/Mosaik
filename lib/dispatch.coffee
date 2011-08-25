arrayfy = require('./util').arrayfy

module.exports.completeDependsPreparesArrays = completeDependsPreparesArrays = (config) ->
    for name, func of config
        func.depends = arrayfy(func.depends)
        func.prepares = arrayfy(func.prepares)
        for dependency in func.depends
            dependency = config[dependency]
            dependency.prepares = arrayfy(dependency.prepares)
            dependency.prepares.push(name) if name not in dependency.prepares
        for follower in func.prepares
            follower = config[follower]
            follower.depends = arrayfy(follower.depends)
            follower.depends.push(name) if name not in follower.depends
    config

module.exports.getDispatchFunction = (config) ->
    completeDependsPreparesArrays(config)
    __dispatchInit = {prepares: []}
    __dispatchFinish = {depends: []}
    dispatch = (func) ->
        (args..., cb) -> 
            if func.prepares
                for name in func.prepares
                    follower = config[name]
                    follower.isReady(args..., cb) if follower.isReady
            else
                __dispatchFinish.isReady(args..., cb)
    isReady = (func) ->
        func.countDone = 0
        (args..., cb) ->
            func.countDone++
            if func.countDone is func.depends.length
                if func is __dispatchFinish
                    cb()
                else if func.method
                    func.method(args..., () -> func.dispatch(args..., cb)) 
                else
                    func.dispatch(args..., cb)
    for name, func of config
        unless func.depends?.length 
            __dispatchInit.prepares.push(name)
            func.depends = arrayfy(func.depends)
            func.depends.push('__dispatchInit')
        unless func.prepares?.length
            __dispatchFinish.depends.push(name)
            func.prepares = arrayfy(func.prepares)
            func.prepares.push('__dispatchFinish')
        func.isReady = isReady(func)
        func.dispatch = dispatch(func)
    config.__dispatchInit = __dispatchInit
    config.__dispatchFinish = __dispatchFinish
    __dispatchFinish.isReady = isReady(__dispatchFinish)

    dispatch(__dispatchInit) 
