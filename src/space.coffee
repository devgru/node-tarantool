Mapping = require './mapping'
compose = require './compose'

DEFAULT_OFFSET = 0
DEFAULT_OPERATIONS = []
DEFAULT_FLAGS = 0
DEFAULT_INDEX = 0
DEFAULT_LIMIT = 4294967295

class Space
    @updateOperations =
        assign      : 0
        add         : 1
        bitwiseAnd  : 2
        bitwiseXor  : 3
        bitwiseOr   : 4
        splice      : 5
        delete      : 6
        insertBefore: 7

    constructor: (@connector, @space, spec, types) ->
        @mapping = new Mapping spec, types
    
    unpackTuples: (callback) -> (returnCode, body) =>
        if body instanceof Array
            callback returnCode, @mapping.unpackTuples body
        else
            callback returnCode, body

    # # space methods # #
    
    insert: (object, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS
        
        tuple = @mapping.packObject object
        @connector.insert @space, tuple, flags, @unpackTuples callback
    
    select: (objects, index, offset, limit, callback) ->
        if offset is undefined
            callback = index
            limit = DEFAULT_LIMIT
            offset = DEFAULT_OFFSET
            index = DEFAULT_INDEX
        else if limit is undefined
            callback = offset
            limit = DEFAULT_LIMIT
            offset = DEFAULT_OFFSET
        else if callback is undefined
            callback = limit
            limit = DEFAULT_LIMIT
        
        tuples = @mapping.packObjects objects
        @connector.select @space, tuples, index, offset, limit, @unpackTuples callback
    
    update: (object, operations, flags, callback) ->
        if flags is undefined
            callback = operations
            operations = DEFAULT_OPERATIONS
            flags = DEFAULT_FLAGS
        else if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        tuple = @mapping.packObject object
        @connector.update @space, tuple, operations, flags, @unpackTuples callback
    
    delete: (object, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        tuple = @mapping.packObject object
        @connector.delete @space, tuple, flags, @unpackTuples callback

    # # update operations # #

    assign: (object) ->
        @mapping.operation object, Space.updateOperations.assign
    add: (object) ->
        @mapping.operation object, Space.updateOperations.add
    and: (object) ->
        @mapping.operation object, Space.updateOperations.and
    xor: (object) ->
        @mapping.operation object, Space.updateOperations.xor
    or: (object) ->
        @mapping.operation object, Space.updateOperations.or
    delete: (object) ->
        @mapping.operation object, Space.updateOperations.delete
    insertBefore: (object) ->
        @mapping.operation object, Space.updateOperations.insertBefore

    splice: (object) ->
        @mapping.splice object, Space.updateOperations.splice

module.exports = Space
