###
# extending object is evil
###
###
module.exports.ObjectExtend = ->
    if not Object::extend
        Object::extend = (other) ->
            for own property, value of other
                this[property] = value 
            @
###

module.exports.merge = (obj1, obj2)->
        Return = {}
        Return[property] = value for own property, value of obj1 
        Return[property] = value for own property, value of obj2 
        Return

module.exports.StringCapitalize = ->
    if not String::capitalize
        String::capitalize = -> @charAt(0).toUpperCase() + @slice(1)

module.exports.arrayfy = (value) ->
    return [] unless value
    return [value] unless value instanceof Array
    value

module.exports.ArrayUnique = () ->
    if not Array::unique
        Array::unique = ->
            newArray = []
            for value in @
                newArray.push(value) unless value in newArray
            newArray




