leb = require 'leb'

module.exports = compose =
    int32s: ->
        buffer = new Buffer arguments.length * 4
        for value, key in arguments
            buffer.writeUInt32LE value, key * 4
        
        return buffer
    
    int32Field: (value) ->
        buffer = new Buffer 5
        buffer.writeUInt8 4, 0
        buffer.writeUInt32LE value, 1
        
        return buffer

    stringField: (value) ->
        # what about string encoding?
        stringBuffer = new Buffer value, 'utf-8' # default
        lengthBuffer = leb.encodeUInt32 stringBuffer.length
        
        return Buffer.concat [lengthBuffer, stringBuffer]
    
    tuple: (tuple) ->
        # copy an array
        tuple = tuple.slice 0
        # todo: compose.tuple should write leb's (varint32) to its fields
        tuple.unshift compose.int32s tuple.length
        
        return Buffer.concat tuple
    
    operation: (operation) ->
        field = compose.int32s operation.field
        operationBuffer = new Buffer [operation.operation]
        
        return Buffer.concat [field, operationBuffer, operation.argument]
