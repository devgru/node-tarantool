Transport = require 'tarantool-transport'
Composer = require './composer'
Space = require './space'

parse = require './parse'

DEFAULT_OFFSET = 0
DEFAULT_LIMIT = 4294967295

class Tarantool
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
    
    
    @connect: (port, host, callback) ->
        new Tarantool Transport.connect port, host, callback
    
    constructor: (@transport) ->
        @composer = new Composer @transport
    
    space: (space) ->
        new Space this, space
    
    
    parseBody: (callback) -> (body) ->
        returnCode = body.readUInt32LE 0
        if returnCode > 0
            callback returnCode, body.toString 'utf-8', 4
        else
            callback returnCode, parse.response body
        return
    
    insert: (space, flags, tuple, callback) ->
        if callback is undefined
            callback = tuple
            tuple = flags
            flags = 0
        
        @composer.insert space, flags, tuple, @parseBody callback
    
    select: (space, index, offset, limit, tuples, callback) ->
        if tuples is undefined
            tuples = offset
            callback = limit
            offset = DEFAULT_OFFSET
            limit = DEFAULT_LIMIT
        else if callback is undefined
            callback = tuples
            tuples = limit
            limit = DEFAULT_LIMIT
        
        @composer.select space, index, offset, limit, tuples, @parseBody callback
    
    update: (space, flags, tuple, operations, callback) ->
        if callback is undefined
            callback = operations
            operations = tuple
            tuple = flags
            flags = 0
        
        @composer.update space, flags, tuple, operations, @parseBody callback
    
    delete: (space, flags, tuple, callback) ->
        if callback is undefined
            callback = tuple
            tuple = flags
            flags = 0
        
        @composer.delete space, flags, tuple, @parseBody callback
    
    call: (flags, proc, tuple, callback) ->
        @composer.call flags, proc, tuple, @parseBody callback
    
    ping: (callback) ->
        @composer.ping callback
    
    end: () ->
        @transport.end()
    
module.exports = Tarantool
