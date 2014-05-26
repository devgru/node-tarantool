compose = require './compose'

class Mapper
    ###
    Mapper is an utility used by Mapping, it parses specs and packs/unpacks objects, tuples, fields and operations
    ###

    transformers: require './default-transformers'

    constructor: (spec) ->
        @types = {}
        @order = {}
        @names = []

        # filling types object
        keys = Object.keys spec
        for key, index in keys
            fieldName = key
            type = spec[fieldName]
            if typeof type is 'string'
                unless -1 is type.indexOf '32'
                    type = '32'
                else unless -1 is type.indexOf '53'
                    type = '53'
                else unless -1 is type.indexOf '64'
                    type = '64'
                if @transformers[type]?
                    type = @transformers[type]
                else
                    throw new Error "there is is no transformer for type #{type}"

            @types[fieldName] = type
            @names[index] = fieldName
            @order[fieldName] = index
        return

    packObjects: (objects) ->
        @packObject object for object in objects

    packObject: (object) ->
        tuple = []

        for key, value of object
            index = @order[key]
            tuple[index] = @packField value, @types[key]
        return tuple

    packProcArgs: (args) ->
        tuple = []
        for key,value of args
            tuple.push @packField value, @transformers['string']

        return tuple

    packField: (value, type) ->
        type.pack value

    unpackTuples: (tuples) ->
        @unpackTuple tuple for tuple in tuples

    unpackTuple: (tuple) ->
        object = {}
        for field, index in tuple
            fieldName = @names[index]
            type = @types[fieldName]

            object[fieldName] = type.unpack field
        return object

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

        Buffer.concat [offset, length, string]

module.exports = Mapper
