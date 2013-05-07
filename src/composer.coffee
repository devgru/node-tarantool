transport = require 'tarantool-transport'

compose = require './compose'

REQUEST_TYPE =
    insert: 13
    select: 17
    update: 19
    delete: 21
    call  : 22
    ping  : 65280
    
class Composer
    @flags =
        none       : 0
        returnTuple: 1
        add        : 2
        replace    : 4
    
    @updateOperations =
        assign      : 0
        add         : 1
        bitwiseAnd  : 2
        bitwiseXor  : 3
        bitwiseOr   : 4
        splice      : 5
        delete      : 6
        insertBefore: 7
    
    
    constructor: (@transport) ->
    
    insert: (space, flags, tuple, callback) ->
        options = compose.int32s space, flags
        
        request = Buffer.concat [options, compose.tuple tuple]
        
        @request REQUEST_TYPE.insert, request, callback
    
    select: (space, index, offset, limit, tuples, callback) ->
        options = compose.int32s space, index, offset, limit, tuples.length
        buffers = tuples.map compose.tuple
        buffers.unshift options
        request = Buffer.concat buffers
        
        @request REQUEST_TYPE.select, request, callback
    
    update: (space, flags, tuple, operations, callback) ->
        options = compose.int32s space, flags
        tuple = compose.tuple tuple
        count = compose.int32s operations.length
        operations = operations.map compose.operation
        
        request = Buffer.concat [options, tuple, count, operations]
        
        @request REQUEST_TYPE.update, request, callback
    
    delete: (space, flags, tuple, callback) ->
        options = compose.int32s space, flags
        request = Buffer.concat [options, compose.tuple tuple]
        
        @request REQUEST_TYPE.delete, request, callback
    
    call: (flags, proc, tuple, callback) ->
        flags = compose.int32s flags
        proc = compose.field proc
        tuple = compose.tuple tuple
        request = Buffer.concat [flags, proc, tuple]

        @request REQUEST_TYPE.call, request, callback
    
    ping: (callback) ->
        @request REQUEST_TYPE.ping, '', callback
    
    request: (type, body, callback) ->
        @transport.request type, body, callback
    
module.exports = Composer
