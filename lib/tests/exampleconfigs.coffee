###
possibles:
    route: String # Route which fires this block
    type: ['POST', 'GET', 'PUT', 'DELETE'] # Request type which fires this block
    childs: Object # Childs to include in this block
    method: String # Module/Method to use to render this block
    params: Object # Params to add to render this block
    middleware: Object # Middleware to execute before proceed to this block
    template: String # Template to use to render this block
    sortorder: Number # Sort order to change possition of block to others of the same level
    remove: Array # names of block to remove from childs blocks
    extends: take configuration from other node
###
module.exports =
    'foo':
        routes: 'foo/'
        type: 'GET'
        childs:
            'header':
                childs:
                    'userlogin':
                        routes: ['user/login', 'nutzer/einloggen']
                        middlewares:
                            'bazFinder':
                                method: 'baz/finder'
                        method: 'user/login'
                        sortorder: 2
                    'menu': 
                        method: 'page/header'
                        sortorder: 1
    'bar':
        routes: 'bar/:barId'
        extends: 'foo'
        middlewares:
            'barFinder':
                depends: ['fooFinder', 'bazFinder']
                method: 'bar/finder'
        childs:
            'header':
                childs:
                    'userlogin': 'remove'
            'content':
                method: 'cms/site'
                params: 
                    barid: 'barId'
