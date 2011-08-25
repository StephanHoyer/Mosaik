should = require 'should'
dispatch = require '../dispatch'
middleware = {}
func = (i) ->
    (result, done) -> 
        result.data += i
        done() if done
middleware['M'+i] = func(i) for i in [1..10]

#test generated middleware

result = 
    data: ''
middleware.M1(result)
middleware.M3(result)
middleware.M2(result)
result.data.should.eql('132')

###

Middleware Mx

(args, done) ->
    doSomething(args)
    done()


or asyncron

(args, done) ->
    doSomethingAsyncron(done)

or

(args, done) ->
    doSomethingAsyncron((err) ->
        done() unless err
    )

###

###
# Test completion of depends and prepares
###

completeConfig =
    'mw1':
        name: 'mw1'
        method: middleware.M1
        depends: ['mw2']
        prepares: []
    'mw2':
        name: 'mw2'
        method: middleware.M2
        depends: []
        prepares: ['mw1']

config2 =
    'mw1':
        name: 'mw1'
        method: middleware.M1
    'mw2':
        name: 'mw2'
        method: middleware.M2
        prepares: ['mw1']
config1 =
    'mw1':
        name: 'mw1'
        method: middleware.M1
        depends: ['mw2']
    'mw2':
        name: 'mw2'
        method: middleware.M2

dispatch.should.respondTo('completeDependsPreparesArrays')
should.deepEqual(
    completeConfig,
    dispatch.completeDependsPreparesArrays(config1)
)
should.deepEqual(
    completeConfig
    dispatch.completeDependsPreparesArrays(config2)
)


completeConfig =
    'mw1':
        name: 'mw1'
        method: middleware.M1
        depends: ['mw2']
        prepares: []
    'mw2':
        name: 'mw2'
        method: middleware.M2
        depends: []
        prepares: ['mw1', 'mw3']
    'mw3':
        name: 'mw3'
        method: middleware.M3
        depends: ['mw2']
        prepares: []

config =
    'mw1':
        name: 'mw1'
        method: middleware.M1
    'mw2':
        name: 'mw2'
        method: middleware.M2
        prepares: ['mw1']
    'mw3':
        name: 'mw3'
        method: middleware.M3
        depends: ['mw2']

should.deepEqual(
    completeConfig,
    dispatch.completeDependsPreparesArrays(config)
)

###
M2 -> M1


main: (args) -> M2(args, () -> M1(args))

###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        name: 'mw1'
        method: middleware.M1
        depends: ['mw2']
    'mw2':
        name: 'mw2'
        method: middleware.M2
        prepares: ['mw1']
)
func(result, ()->
    result.data.should.eql('21')
)

###
------------------------

M3 -> M2 -> M1

main: (args) -> M3(args, () -> M2(args, () -> M1(args)))

###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2']
    'mw2':
        method: middleware.M2
        depends: ['mw3']
        prepares: ['mw1']
    'mw3':
        method: middleware.M3
        prepares: ['mw2']
)
func(result, ()->
    result.data.should.eql('321')
)

###

------------------------

M3 ->
      M1
M2 -> 

main: (args) ->
        countDone = 0
        M3andM2ready = () -> 
            countDone++
            M1(args) if countDone is 2
        M3(args, M3andM2ready)
        M2(args, M3andM2ready)

###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2', 'mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw1']
    'mw3':
        method: middleware.M3
        prepares: ['mw1']
)
func(result, ()->
    ['321', '231'].should.contain(result.data)
)

###

------------------------

   -> M2
M3
   -> M1

main: (args) ->
        M3(args, () ->
            M1(args)
            M2(args)
###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        prepares: ['mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw3']
    'mw3':
        method: middleware.M3
        prepares: ['mw2', 'mw3']
)
func(result, ()->
    ['321', '312'].should.contain(result.data)
)

###


------------------------

M4 ->    -> M1
      M3
M5 ->    -> M2

main: (args) ->
        countDone = 0
        M4andM5ready = () ->
            countDone++
            if countDone is 2 then M3(args, () ->
                M1(args)
                M2(args)
            )
        M4(args, M4andM5ready)
        M5(args, M4andM5ready)
###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw3']
    'mw2':
        method: middleware.M2
        depends: ['mw3']
    'mw3':
        method: middleware.M3
        prepares: ['mw1','mw2']
        depends: ['mw4','mw5']
    'mw4':
        method: middleware.M4
        prepares: ['mw3']
    'mw5':
        method: middleware.M5
        prepares: ['mw3']
)
func(result, ()->
    ['54321', '45321', '54312', '45312'].should.contain(result.data)
)

###


------------------------

      M2
M4 ->    -> M1
      M3

main: (args) ->
        M4(args, () ->
            countDone = 0
            M2andM3ready = () ->
                countDone++
                M1(args) if countDone is 2 
            M2(args, M2andM3ready)
            M3(args, M2andM3ready)

###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2', 'mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw1']
        depends: ['mw4']
    'mw3':
        method: middleware.M3
        prepares: ['mw1']
        depends: ['mw4']
    'mw4':
        method: middleware.M4
        prepares: ['mw3', 'mw2']
)
func(result, ()->
    ['4231', '4321'].should.contain(result.data)
)

###

------------------------

      M2
M4 ->    -> M1
      M3
M5 ->

main: (args) ->
        M4andM5ready = () ->
            countDone = 0
            M2andM3ready = () ->
                countDone++
                M1(args) if countDone is 2
            M2(args, M2andM3ready)
            M3(args, M2andM3ready)
        M4(args, M4andM5ready)
        M5(args, M4andM5ready)
###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2', 'mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw1']
        depends: ['mw4']
    'mw3':
        method: middleware.M3
        prepares: ['mw1']
        depends: ['mw4', 'mw5']
    'mw4':
        method: middleware.M4
        prepares: ['mw3', 'mw2']
    'mw5':
        method: middleware.M5
        prepares: ['mw3']
)
func(result, ()->
    ['45231', '54231', '42531', '54321'].should.contain(result.data)
)

###


------------------------

M4 -> M3 ->
            M1
      M2 -> 

main: (args) ->
        countDone = 0
        M3andM2ready = () -> 
            countDone++
            M1(args) if countDone is 2
        M4(args, () -> M3(args, M3andM2ready()))
        M2(args, M3andM2ready)
###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2', 'mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw1']
    'mw3':
        method: middleware.M3
        prepares: ['mw1']
        depends: ['mw4']
    'mw4':
        method: middleware.M4
        prepares: ['mw3']
)
func(result, ()->
    ['4231', '2431'].should.contain(result.data)
)

###


------------------------

            M2
M6 -> M4 ->    -> M1
            M3
      M5 ->

main: (args) ->
        M4andM5ready = () ->
            countDone = 0
            M2andM3ready = () ->
                countDone++
                M1(args) if countDone is 2
            M2(args, M2andM3ready)
            M3(args, M2andM3ready)
        M6(args, () -> M4(args, M4andM5ready()))
        M5(args, M4andM5ready)

###

result = 
    data: ''
func = dispatch.getDispatchFunction(
    'mw1':
        method: middleware.M1
        depends: ['mw2', 'mw3']
    'mw2':
        method: middleware.M2
        prepares: ['mw1']
        depends: ['mw4']
    'mw3':
        method: middleware.M3
        prepares: ['mw1']
        depends: ['mw4', 'mw5']
    'mw4':
        method: middleware.M4
        prepares: ['mw3', 'mw2']
        depends: ['mw6']
    'mw5':
        method: middleware.M5
        prepares: ['mw3']
    'mw6':
        method: middleware.M6
        prepares: ['mw4']
)
func(result, ()->
    ['564231', '564321', '645231', '654231', '642531', '654321'].should.contain(result.data)
)

###
Test two functions running at once to avoid interference

###

result1 = 
    data: ''
func1 = dispatch.getDispatchFunction(
    'mw1':
        name: 'mw1'
        method: middleware.M1
        depends: ['mw2']
    'mw2':
        name: 'mw2'
        method: middleware.M2
        prepares: ['mw1']
)

result2 = 
    data: ''
func2 = dispatch.getDispatchFunction(
    'mw1':
        name: 'mw1'
        method: middleware.M1
        prepares: ['mw2']
    'mw2':
        name: 'mw2'
        method: middleware.M2
        depends: ['mw1']
)
func1(result1, () ->
    result1.data.should.eql('21')
)
func2(result2, () ->
    result2.data.should.eql('12')
)
func1(result1, () ->
    result1.data.should.eql('21')
)

