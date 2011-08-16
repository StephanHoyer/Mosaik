module.exports.Base = class Base
    constructor: (@message, @code, @type) ->
        if typeof @message is 'object'
            @code = @message.code
            @type = @message.type
            @message = @message.message
