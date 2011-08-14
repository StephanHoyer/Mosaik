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

###
# Test default primary key
###

baz.should.have.property('pk', baz._id)

###
# Test custom primary key
###

Braz = new models.Base(
    name: 'braz'
    pk: 'slug'
    fields: 
        slug:
            type: String
)
braz = Braz.create(
    slug: 'doo'
)
braz.should.have.property('pk', braz.slug)

###
# Test change primary key
###

braz.slug = 'dar' 
braz.should.have.property('pk', braz.slug)

###
# Test find by pk
###
Baz.should.respondTo('findByPk')
Baz.findOne({}, (err, baz) ->
    Baz.findByPk(baz.pk, (err, foundBaz) -> 
        should.not.exist(err)
        should.exist(foundBaz)
        foundBaz.pk.should.eql(baz.pk)
    )
)

###
# Test non-interference beween models
###

One = new models.Base(
    name: 'One'
    fields:
        one: String
)

Two = new models.Base(
    name: 'Two'
    fields:
        two: String
)
One.configuration.fields.should.have.property('one')
One.configuration.fields.should.not.have.property('two')
Two.configuration.fields.should.have.property('two')
Two.configuration.fields.should.not.have.property('one')

###
# Test find by attribute
###

Baz.should.respondTo('findByFoo')
Baz.findByFoo('fooo', (err, fooBazes) ->
    fooBazes.should.have.property('length')
    fooBazes.length.should.be.above(0)
    fooBazes[0].should.have.property('foo', 'fooo')
)

###
# Cleanup
###
baz.remove()
