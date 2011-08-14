mongoose = require 'mongoose'

require('./util').capitalize()

mongoose.connect('mongodb://localhost/testexpressway');

module.exports.Base = class Base
    constructor: (@configuration) ->
        @Model = mongoose.model(@configuration.name, new mongoose.Schema(@configuration.fields))
        @Model::[name] = method for name, method of @configuration.methods
        @Model::__defineGetter__('class', () => @)
        @pkField = configuration.pk or '_id' 
        @Model::__defineGetter__('pk', () -> @[@class.pkField])
        # Add findByAttribute methods
        for key of configuration.fields
            ((key) =>
                @['findBy' + key.capitalize()] = (value, cb) => 
                    query = {}
                    query[key] = value
                    @find(query, cb)
            )(key)
        # Inject some of Models functions to Base
        for name, method of @Model
            if  name in ['find', 'findOne', 'findById'] and not Base::[name] 
                ((name, method, model) ->
                    Base::[name] = (args...) ->
                        method.apply(model, args)
                )(name, method, @Model)
    create: (data) =>
        new @Model(data)

    findByPk: (value, cb) =>
        throw new Error('no value given') if not value
        query = {}
        query[@pkField] = value
        @findOne(query, cb)
