should = require 'should'
util = require('../util')
util.ObjectExtend()

{}.should.respondTo('extend')
{}.extend {}.should.eql({})
(a:1).extend(b:2).should.eql(a:1,b:2)

util.StringCapitalize()
'foo'.capitalize().should.eql('Foo')

util.should.respondTo('arrayfy')
util.arrayfy('foo').should.eql(['foo'])
util.arrayfy(undefined).should.eql([])
util.arrayfy(123).should.eql([123])
util.arrayfy([123]).should.eql([123])

util.should.respondTo('ArrayUnique')
util.ArrayUnique()

[].should.respondTo('unique')
[].unique().should.eql([])
[123,123].unique().should.eql([123])
['123',123].unique().should.eql(['123',123])

