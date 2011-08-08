should = require 'should'
controllers = require '../controllers'

controllers.should.respondTo('Crud')
Crud = controllers.Crud
crud = new Crud('model','foo')

crud.should.have.property('routes')
crud.routes.should.have.property('new', 'foo/new')
crud.routes.should.have.property('list', 'foo/list')
crud.routes.should.have.property('delete', 'foo/delete')
crud.routes.should.have.property('view', 'foo/view')
crud.routes.should.have.property('edit', 'foo/edit')
