leb = require 'leb'

module.exports = compose =
    int32s: ->
        buffer = new Buffer arguments.length * 4
        for value, key in arguments
            buffer.writeUInt32LE value, key * 4
        
        return buffer
    
    field: (value) ->
        # only non-negative integer or string
        if typeof value is 'number' and value % 1 is 0 and value >= 0
            # 64 bit?
            if value > 4294967296
                field = new Buffer 9
                field.writeUInt8 8, 0
                field.writeUInt64LE value, 1
            else
                field = new Buffer 5
                field.writeUInt8 4, 0
                field.writeUInt32LE value, 1
        else if typeof value is 'string'
            # what about string encoding?
            stringBuffer = new Buffer value, 'utf-8' # default
            lengthBuffer = leb.encodeUInt32 stringBuffer.length
            field = Buffer.concat [lengthBuffer, stringBuffer]
        else if Buffer.isBuffer value
            # we can call it 'binary string' in node
            lengthBuffer = leb.encodeUInt32 value.length
            field = Buffer.concat [bufferLength, value]
        else
            throw new Error 'bad argument for tarantool field: ' + value

        return field
    
    tuple: (tuple) ->
        fields = tuple.map compose.field
        fields.unshift compose.int32s tuple.length
        
        return Buffer.concat fields
    
    operation: (operation) ->
        field = compose.int32s operation.field
        operation = new Buffer [operation.operation]
        if operation.operation is 5 # remove splice magic number
            argument = compose.spliceField operation.argument
        else
            argument = compose.field operation.argument
        
        return Buffer.concat [field, operation, argument]
    
    spliceField: (argument) ->
        offset = compose.field argument.offset
        length = compose.field argument.length
        string = compose.field argument.string
        size = leb.encodeUInt32 offset.length + length.length + string.length
        
        return Buffer.concat [size, offset, length, string]

