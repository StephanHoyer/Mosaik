################################################
# Simple Hello world app
################################################
module.exports.config = 
    childs:
        'helloWorld':
            route: /.*/
            method: () -> 'Hello World'

###

Dependency tree

route: helloWorld
    'RESPONSE'
        'helloWorld'
###

################################################
# Example with db interaction
################################################

renderObject = (req, res) ->
    req.object.renderWithTemplate(res.template)

###
# req: Request object
#   req.route blockname of route which initially catched the request
# res: Response object with some additional data
#   res.forward(url/blockname) method to forward request
#   res.redirect(url/blockname) method to redirect request
# done(): method to finish this middleware and continue with next middleware
# done(): method to stop rendering an continue with next matching route
###
loadFromDb = (req, res, done, next) ->
    db.loadSomethigById(req.id, (err, something) ->
        done() if err
        req.object = something
        done()
    )

module.exports.config = 
    childs:
        'showSomeDbContent':
            route: /.*/
            method: renderObject
            template: 'niceTemplate'
            middlewares:
                'loadFromDb':
                    method: loadfromDb

###

Dependency tree

route: helloWorld
    'RESPONSE'
        'showSomeDbContent'
            'loadFromDb'

################################################
# Example with middlewaredepencies
################################################

checkLoginState = (req, res, done, next) ->
    done() if isAllowed(req.session.user)
    req.session.back = req.route
    res.redirect('login')
checkLogin = (req, res, done, next) ->
    done() if req.type is 'GET'
    db.checkUser(req.data.username, req.data.password, (err, user) ->
        done() if err
        req.session.user = user
        res.redirect(req.session.back)

module.exports.config = 
    childs:
        'login'
            route: 'user/login'
            type: ['POST', 'GET']
            method: renderForm
            middlewares:
                'checkLogin'
                    method: checkLogin

        'showSomeDbContentWhichRequiresLogin':
            route: /.*/
            method: renderObject
            template: 'niceTemplate'
            middlewares:
                'loadFromDb':
                    method: loadfromDb
                    depends: 
                        'checkLogin':
                            method: checkLoginState
                            depends: 'mosaik-session' # core module which sets session to req object

###

Dependency tree

route: showSomeDbContentWhichRequiresLogin

    'RESPONSE'
        'showSomeDbContent'
            'loadFromDb'
                'checkLogin'
                    'mosaik-session'
###
