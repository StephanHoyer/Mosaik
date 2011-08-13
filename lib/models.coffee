mongoose = require 'mongoose'

mongoose.connect('mongodb://localhost/testexpressway');

module.exports.Base = class Base
    constructor: (@configuration) ->
        @Model = mongoose.model(@configuration.name, new mongoose.Schema(@configuration.fields))
        @Model::[name] = method for name, method of @configuration.methods
        @Model::__defineGetter__('class', () => @)
        @pkField = configuration.pk or '_id' 
        @Model::__defineGetter__('pk', () -> @[@class.pkField])

    create: (data) =>
        instance = new @Model(data)

    findByPk: (value, cb) =>
        throw new Error('no value given') if not value
        query = {}
        query[@pkField] = value
        @findOne(query, cb)
    ###
    # @TODO
    #
    # Tried to inject all methods of @Model to this, but i didn't get it
    # Here is, what i come up with:
    #
    # for name, method of @Model
    #     if typeof method is 'function'
    #         Base::[name] = @Model[name]
    #
    # But it does not work. So i hardcoded some functions
    ###
    findOne: (args...) =>
        @Model.findOne(args...)
    find: (args...) =>
        @Model.find(args...)
