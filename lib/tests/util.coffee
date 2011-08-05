should = require 'should'
ew = require '../util'

{}.should.respondTo 'extend'
{}.extend {}.should.eql {}
(a:1).extend(b:2).should.eql a:1,b:2

