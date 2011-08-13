should = require 'should'
models = require '../models'

###
# Test class creation
###

models.should.respondTo('Base')

Baz = new models.Base(
    name: 'baz'
    fields: 
        foo:
            type: String
        bar:
            type: Number
    methods:
        foobar: (inter) -> @foo + inter + @bar
)
Baz.should.respondTo('create')

###
# Test instance creation
###

baz = Baz.create(
    foo: 'fooo'
    bar: 123
    foz: 'aaa'
)

baz.should.have.property('bar')
baz.bar.valueOf().should.eql(123)

baz.should.have.property('foo', 'fooo')

###
# Test save
###

baz.should.respondTo('save')
baz.save((err) -> should.not.exist(err))

###
# Test query for one instance
###

Baz.should.respondTo('find')
Baz.findOne({foo: 'fooo'}, (err, foundBaz) -> 
    foundBaz.should.have.property(key, value) for key, value in baz
)

###
# Test query for multiple instances
###

Baz.find({foo: 'fooo'}, (err, bazes) -> 
    bazes.should.have.property('length')
    bazes.length.should.be.above(0)
)

###
# Test embeded methods
###

baz.should.respondTo('foobar')
baz.foobar('biz').should.eql('fooobiz123')
