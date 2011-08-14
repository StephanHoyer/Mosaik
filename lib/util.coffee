module.exports.extend = ->
    if not Object::extend
        Object::extend = (other) ->
            for own property, value of other
                this[property] = value 
            this

module.exports.capitalize = ->
    if not String::capitalize
        String::capitalize = -> @charAt(0).toUpperCase() + @slice(1)

