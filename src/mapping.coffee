leb = require 'leb'
compose = require './compose'

class Mapping
    # {
    #   id: 'string',
    #   name: 'i32'
    #   fieldName: type
    # }
    transformers:
        string:
            pack: (value) -> new Buffer value, 'utf-8'
            unpack: (buffer) -> buffer.toString 'utf-8'
        buffer:
            pack: (value) -> value
            unpack: (buffer) -> buffer
        object:
            pack: (value) -> new Buffer JSON.stringify(value), 'utf-8'
            unpack: (buffer) -> JSON.parse buffer.toString 'utf-8'
        32:
            pack: (value) ->
                field = new Buffer 4
                field.writeUInt32LE value, 0
                field
            unpack: (buffer) -> buffer.readUInt32LE 0

    types: {}
    order: {}
    names: []

    constructor: (spec, transformers) ->
        # filling types object
        keys = Object.keys spec
        for key, index in keys
            fieldName = key
            @types[fieldName] = spec[fieldName]
            @names[index] = fieldName
            @order[fieldName] = index

        # add custom transformers if any
        return if not transformers?
        for key, transformer of transformers
            @transformers[key] = transformer

    packObjects: (objects) ->
        objects.map @packObject.bind @

    packObject: (object) ->
        tuple = []

        for key, value of object
            index = @order[key]
            tuple[index] = @packField value, @types[key]
        return tuple

    packField: (value, type) ->
        field = (@getTransformer type).pack value

        return Buffer.concat [leb.encodeUInt32(field.length), field]

    unpackTuples: (tuples) ->
        tuples.map @unpackTuple.bind @

    unpackTuple: (tuple) ->
        object = {}
        for field, index in tuple
            fieldName = @names[index]
            type = @types[fieldName]

            object[fieldName] = (@getTransformer type).unpack field
        return object

    getTransformer: (type) ->
        if -1 < type.indexOf '32' then type = '32'
        else if -1 < type.indexOf '64' then type = '64'
        throw new Error "there is is not transformer for type #{type}" if not @transformers[type]?
        return @transformers[type]

    operation: (object, operation) ->
        key = (Object.keys object)[0]
        value = object[key]
        type = @types[key]

        field: @order[key]
        operation: operation
        argument: @packField value, type

    splice: (object, operation) ->
        key = (Object.keys object)[0]
        value = object[key]

        field: @order[key]
        operation: operation
        argument: @packSpliceArgument value

    packSpliceArgument: (argument) ->
        offset = compose.int32Field argument.offset
        length = compose.int32Field argument.length
        string = compose.stringField argument.string
        size = leb.encodeUInt32 offset.length + length.length + string.length

        Buffer.concat [size, offset, length, string]


module.exports = Mapping