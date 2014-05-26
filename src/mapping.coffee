Mapper = require './mapper'

DEFAULT_OFFSET = 0
DEFAULT_OPERATIONS = []
DEFAULT_FLAGS = 0
DEFAULT_INDEX = 0
DEFAULT_LIMIT = 4294967295


class Mapping
    ###
    Mapping class is API level which cares about mapping fields to their names and positions
    ###
    
    @updateOperations =
        assign      : 0
        add         : 1
        bitwiseAnd  : 2
        bitwiseXor  : 3
        bitwiseOr   : 4
        splice      : 5
        delete      : 6
        insertBefore: 7
    
    constructor: (@connector, spec) ->
        @mapper = new Mapper spec
    
    parseBody: (callback) -> (returnCode, body) =>
        if Array.isArray body
            callback returnCode, @mapper.unpackTuples body
        else
            callback returnCode, body
    
    # # requests # #

    insert: (space, object, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS
        
        tuple = @mapper.packObject object
        @connector.insert space, tuple, flags, @parseBody callback
    
    select: (space, objects, index, offset, limit, callback) ->
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
        
        tuples = @mapper.packObjects objects
        @connector.select space, tuples, index, offset, limit, @parseBody callback
    
    update: (space, object, operations, flags, callback) ->
        if flags is undefined
            callback = operations
            operations = DEFAULT_OPERATIONS
            flags = DEFAULT_FLAGS
        else if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS
        
        tuple = @mapper.packObject object
        @connector.update space, tuple, operations, flags, @parseBody callback
    
    delete: (space, object, flags, callback) ->
        # handle delete operation
        return @deleteOperation space unless object or flags or callback
        
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS
        
        tuple = @mapper.packObject object
        @connector.delete space, tuple, flags, @parseBody callback
    
    call: (proc, args, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = 0
        
        tuple = @mapper.packProcArgs args
        @connector.call proc, tuple, flags, @parseBody callback
    
    # # update operations # #
    
    assign: (object) ->
        @mapper.operation object, Mapping.updateOperations.assign
    add: (object) ->
        @mapper.operation object, Mapping.updateOperations.add
    and: (object) ->
        @mapper.operation object, Mapping.updateOperations.and
    xor: (object) ->
        @mapper.operation object, Mapping.updateOperations.xor
    or: (object) ->
        @mapper.operation object, Mapping.updateOperations.or
    insertBefore: (object) ->
        @mapper.operation object, Mapping.updateOperations.insertBefore
    
    # clashes with delete request
    deleteOperation: (object) ->
        @mapper.operation object, Mapping.updateOperations.delete
    
    splice: (object) ->
        @mapper.splice object, Mapping.updateOperations.splice

module.exports = Mapping
