should = require 'should'
Exception = require('../exception').Base

exception = new Exception()

should.exist(exception)
exception.should.eql(
    message: undefined
    code: undefined
    type: undefined
)

exception = new Exception('wrong foo', 123, 'foo')

should.exist(exception)
exception.should.eql(
    message: 'wrong foo'
    code: 123
    type: 'foo'
)

exception = new Exception(
    code: 123
    message: 'wrong foo'
    type: 'foo'
)

should.exist(exception)
exception.should.eql(
    message: 'wrong foo'
    code: 123
    type: 'foo'
)

("" +exception).should.eql("Exception of type 'foo' with code 123: wrong foo")
