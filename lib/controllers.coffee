module.exports.Base = class Base

module.exports.Crud = class Crud extends Base
    constructor: (@model, routes, prefixes={new : 'new', list : 'list', view : 'view', edit : 'edit', delete : 'delete'}) ->
        if typeof(routes) is 'string'
            @routes = {}
            for key, action of prefixes
                @routes[key] = routes + '/' + action
