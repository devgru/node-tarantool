ber = require './ber'

module.exports = compose =
    ###
    Compose is a low-level utility, packing low-level structures: int32, varint (BER-128 used in Perl).
    ###
    
    int32s: ->
        buffer = new Buffer arguments.length * 4
        for value, key in arguments
            buffer.writeUInt32LE value, key * 4
        return buffer
    
    int32Field: (value) ->
        buffer = new Buffer 5
        buffer.writeUInt8 4, 0
        buffer.writeUInt32LE value, 1
        
        buffer

    stringField: (value) ->
        # what about string encoding?
        stringBuffer = new Buffer value, 'utf-8' # default
        lengthBuffer = ber.encode stringBuffer.length
        
        Buffer.concat [lengthBuffer, stringBuffer]
    
    tuple: (tuple) ->
        buffers = [compose.int32s tuple.length]
        for field in tuple
            buffers.push ber.encode field.length
            buffers.push field
        
        Buffer.concat buffers
    
    operation: (operation) ->
        field = compose.int32s operation.field
        operationBuffer = new Buffer [operation.operation]
        length = ber.encode operation.argument.length
        
        Buffer.concat [field, operationBuffer, length, operation.argument]
