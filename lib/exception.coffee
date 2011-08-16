module.exports.Base = class Base
    constructor: (@message, @code, @type) ->
        if typeof @message is "object"
            @code = @message.code
            @type = @message.type
            @message = @message.message
    toString: ->
        typeMessage = " of type '#{@type}'" if @type
        codeMessage = " with code #{@code}" if @code
        messageMessage = ": #{@message}" if @message
        ["Exception", typeMessage, codeMessage, messageMessage].join('')
