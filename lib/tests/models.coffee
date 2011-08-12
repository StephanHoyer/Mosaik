should = require 'should'
models = require '../models'

###
#
# Test models
#
###

models.should.respondTo('Base')

Baz = new models.Base(
    name: 'baz'
    fields: 
        foo:
            type: String
        bar:
            type: Number
)
Baz.should.respondTo('create')

baz = Baz.create(
    foo: 'fooo'
    bar: 123
)
baz.should.have.property('bar')
baz.bar.valueOf().should.eql(123)

baz.should.have.property('foo', 'fooo')

