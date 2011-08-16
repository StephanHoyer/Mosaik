module.exports.Config = class Config
    constructor: (@config={}) ->

    merge: (config={}) ->
        
        if config.router
            for key, value in config.router
                console.log(key)
                @config.router.key = value
        @
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
                            for route in value when typeof route isnt 'string'
                                    throw new Error("Block '#{name}': Route '#{route}' should be of type String but is of type '#{typeof route}'") 
                        when 'types'
                            value = [value] if value not instanceof Array
                            for type in value when type not in ['GET', 'POST', 'PUT', 'DELETE']
                                throw new Error("Block '#{name}': Type '#{type}' is not allowed, use one of 'GET', 'POST', 'PUT', 'DELETE'")
                            
                        else
                            throw new Error("Block '#{name}': Unknown router key '#{key}'")
            else 
                throw new Error("Block '#{name}': Unknown config type #{type}")
        @
