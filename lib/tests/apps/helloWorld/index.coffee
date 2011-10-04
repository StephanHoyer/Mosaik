################################################
# Simple Hello world app
################################################
module.exports.config = 
    blocks:
        'helloWorld':
            route: /.*/
            actions: 
                'render': (req, block, action) -> block.send('Hello World')

###

Dependency tree

route: helloWorld
    'RESPONSE'
        'helloWorld'
###

################################################
# Example with db interaction
################################################

renderObject = (req, block, action) ->
    block.renderWithTemplate(block.template, {'object': block.object})

renderForm = (req, block, action) ->
    req.form.renderWithTemplate(res.template)

###
# req: Request object
#   req.route blockname of route which initially catched the request
#   req.forward(url/blockname) method to forward request
#   req.redirect(url/blockname) method to redirect request
#   next(): method to stop rendering an continue with next matching route
# action:
#   done(): method to finish this action and continue with next action
###
loadFromDb = (req, block, action) ->
    db.loadSomethigById(req.id, (err, something) ->
        action.done() if err
        block.object = something
        action.done()
    )

module.exports.config = 
    childs:
        'showSomeDbContent':
            route: '/.*/'
            template: 'niceTemplate'
            actions:
                'render': 
                    method: renderObject
                    depends: 'loadFromDb'
                'loadFromDb': loadFromDb

###

Dependency tree

route: helloWorld
    'render'
        'loadFromDb'

################################################
# Example with depencies
################################################

checkLoginState = (req, block, action) ->
    action.done() if isAllowed(req.session.user)
    req.session.back = req.route
    req.redirect('login')
checkLogin = (req, block, action) ->
    action.done() if req.type is 'GET'
    db.checkUser(req.data.username, req.data.password, err, user) ->
        action.done() if err
        req.session.user = user
        req.redirect(req.session.back)
        action.done()

module.exports.config = 
    blocks:
        'login':
            route: 'user/login'
            type: ['POST', 'GET']
            actions:
                'checkLogin': checkLogin

        'showSomeDbContentWhichRequiresLogin':
            route: /.*/
            template: 'niceTemplate'
            actions:
                'render': 
                    method: renderObject
                    depends: 'loadFromDb'
                'loadFromDb':
                    method: loadFromDb
                    depends: 'checkLogin'
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
