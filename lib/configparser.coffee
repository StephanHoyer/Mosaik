module.exports.Config = class Config
    constructor: (@config={}) ->
        @routes = {} 
        @middlewares = {}

    merge: (config={}) ->
        @validate(config)
        @recursiveMerge(@config, config) 
        @validate(@config)
        @

    recursiveMerge: (obj1, obj2) ->
        for key, value of obj2
            if key in ['routes', 'depends']
                obj1[key] = @arrayfy(obj1[key]).concat(@arrayfy(value))
            else
                if obj1[key] and typeof obj1[key] is 'object' and typeof value is 'object'
                    obj1[key] = @recursiveMerge(obj1[key], value)
                else
                    obj1[key] = value
            @collectRoutes(value) if key is 'childs'
        obj1
    
    arrayfy: (value) ->
        return [] unless value
        return [value] unless value instanceof Array
        value

    collectRoutes: (childs) ->
        for key, value of childs
            null
        
    validate: (config={}, type='base', name='ROOT') ->
        switch type
            when 'base'
                for key, value of config
                    switch key
                        when 'childs'
                            for name, config of config.childs
                                @validate(config, 'base', name)
                        when 'routes'
                            value = [value] if value not instanceof Array
                            for route in value 
                                @validateString(
                                    route,
                                    "Block '#{name}': Route '#{route}' should be of type String but is of type '#{typeof route}'"
                                )
                        when 'types'
                            value = [value] if value not instanceof Array
                            for type in value when type not in ['GET', 'POST', 'PUT', 'DELETE']
                                throw new Error("Block '#{name}': Type '#{type}' is not allowed, use one of 'GET', 'POST', 'PUT', 'DELETE'")
                        when 'middlewares'
                            @validateMiddleware(middlewareConfig, name) for name, middlewareConfig of value
                        when 'method'
                            @validateFunction(
                                value,
                                "Middleware '#{name}': Method '#{value}' should be of type Function but is of type '#{typeof value}'"
                            )
                        when 'extends'
                                @validateString(
                                    value,
                                    "Block '#{name}': Block name to extend '#{value}' should be of type String but is of type '#{typeof value}'"
                                )
                        when 'sortorder'
                                @validateNumber(
                                    value,
                                    "Block '#{name}': Block sortorder '#{value}' should be of type Number but is of type '#{typeof value}'"
                                )
                        else
                            throw new Error("Block '#{name}': Unknown router key '#{key}'")
            else 
                throw new Error("Block '#{name}': Unknown config type '#{type}'")
        @

    validateMiddleware: (config={}, name) ->
        throw new Error("Middleware '#{name}': No method defined") if not config.method
        for key, value of config
            switch key
                when 'method'
                    @validateFunction(
                        value,
                        "Middleware '#{name}': Method '#{value}' should be of type Function but is of type '#{typeof value}'"
                    ) 
                when 'depends'
                    value = [value] if value not instanceof Array
                    for dependency in value 
                        @validateString(
                            dependency, 
                            "Middleware '#{name}': Dependency '#{dependency}' should be of type String but is of type '#{typeof dependency}'"
                        )
                else 
                    throw new Error("Middleware '#{name}': Unknown config key '#{key}'")

    validateNumber: (value, message) ->
        throw new Error(message) if typeof value isnt 'number'
    
    validateString: (value, message) ->
        throw new Error(message) if typeof value isnt 'string'

    validateFunction: (value, message) ->
        throw new Error(message) if typeof value isnt 'function'
