mongoose = require 'mongoose'
Schema   = mongoose.Schema

mongoose.connect('mongodb://localhost/company');

module.exports.Base = class Base
    constructor: (@configuration) ->
        @Model = mongoose.model(@configuration.name, new Schema(@configuration.fields))
    create: (data) ->
        new @Model(data)
###
module.exports.create = (configuration) =>
    #model.

var User = mongoose.model('User', new Schema({
    name: { type: String, validate: [function(v, cb) {
        if ('' == v) {
            cb(false);
            return;
        }
        User.findOne({name: v}, function(err, user) {
            if (err) { cb(true); }
            user ? cb(false) : cb(true);
        });
    }, 'User already exists!']},
    password: { type: String, required: true, set: encrypt }
}));    
###
