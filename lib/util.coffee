Object::extend = (other) ->
    for own property, value of other
        this[property] = value 
    this
