should = require 'should'
controllers = require '../controllers'

###
#
# Test crud controller
#
###

controllers.should.respondTo('Crud')

###
# Test prefixed autoroutes
###
crud = new controllers.Crud('model','foo')
crud.should.have.property('routes')
crud.routes.should.have.property('new', 'foo/new')
crud.routes.should.have.property('list', 'foo/list')
crud.routes.should.have.property('delete', 'foo/delete')
crud.routes.should.have.property('view', 'foo/view')
crud.routes.should.have.property('edit', 'foo/edit')

###
# Test custom prefixed auto routes
###
crud = new controllers.Crud('model','bar', {new: 'wen', list: 'tsil', delete: 'eteled', view: 'weiv', edit: 'tide'})
crud.should.have.property('routes')
crud.routes.should.have.property('new', 'bar/wen')
crud.routes.should.have.property('list', 'bar/tsil')
crud.routes.should.have.property('delete', 'bar/eteled')
crud.routes.should.have.property('view', 'bar/weiv')
crud.routes.should.have.property('edit', 'bar/tide')

###
# Test partial custom prefixed auto routes
###
crud = new controllers.Crud('model','baz', {delete: 'remove'})
crud.should.have.property('routes')
crud.routes.should.have.property('new', 'baz/new')
crud.routes.should.have.property('delete', 'baz/remove')
