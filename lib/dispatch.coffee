module.exports.getDispatchFunction = (config) ->
    init = {prepares: []}
    finish = {depends: []}
    dispatch = (func) ->
        (args..., cb) -> 
            if func.prepares
                for name in func.prepares
                    follower = config[name]
                    follower.isReady(args..., cb) if follower.isReady
            else
                finish.isReady(args..., cb)
    isReady = (func) ->
        func.countDone = 0
        (args..., cb) ->
            func.countDone++
            if func.countDone is func.depends.length
                if func is finish
                    cb()
                else if func.method
                    func.method(args..., () -> func.dispatch(args..., cb)) 
                else
                    func.dispatch(args..., cb)
    for name, func of config
        unless func.depends?.length
            init.prepares.push(name)
            func.depends = ['init'] 
        unless func.prepares?.length
            finish.depends.push(name)
        func.isReady = isReady(func)
        func.dispatch = dispatch(func)
    finish.isReady = isReady(finish)
    dispatch(init) 
