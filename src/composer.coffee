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
    constructor: (@transport) ->
    
    insert: (space, tuple, flags, callback) ->
        options = compose.int32s space, flags
        
        request = Buffer.concat [options, compose.tuple tuple]

        @request REQUEST_TYPE.insert, request, callback
    
    select: (space, tuples, index, offset, limit, callback) ->
        options = compose.int32s space, index, offset, limit, tuples.length
        buffers = tuples.map compose.tuple
        buffers.unshift options
        request = Buffer.concat buffers
        
        @request REQUEST_TYPE.select, request, callback
    
    update: (space, tuple, operations, flags, callback) ->
        options = compose.int32s space, flags
        tuple = compose.tuple tuple
        count = compose.int32s operations.length
        operations = operations.map compose.operation
        operations.unshift count
        operations.unshift tuple
        operations.unshift options

        request = Buffer.concat operations
        
        @request REQUEST_TYPE.update, request, callback
    
    delete: (space, tuple, flags, callback) ->
        options = compose.int32s space, flags
        request = Buffer.concat [options, compose.tuple tuple]
        
        @request REQUEST_TYPE.delete, request, callback
    
    call: (proc, args, flags, callback) ->
        flags = compose.int32s flags
        proc = compose.stringField proc
        tuple = compose.tuple args
        request = Buffer.concat [flags, proc, tuple]

        @request REQUEST_TYPE.call, request, callback
    
    ping: (callback) ->
        @request REQUEST_TYPE.ping, '', callback
    
    request: (type, body, callback) ->
        @transport.request type, body, callback
    
module.exports = Composer
