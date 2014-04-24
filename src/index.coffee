Transport = require 'tarantool-transport'
Space = require './space'
Mapping = require './mapping'

compose = require './compose'
parse = require './parse'

DEFAULT_OFFSET = 0
DEFAULT_OPERATIONS = []
DEFAULT_FLAGS = 0
DEFAULT_INDEX = 0
DEFAULT_LIMIT = 4294967295

REQUEST_TYPE =
    insert: 0x0D
    select: 0x11
    update: 0x13
    delete: 0x15
    call  : 0x16
    ping  : 0xFF00

class Tarantool
    @flags =
        none       : 0
        returnTuple: 1
        add        : 2
        replace    : 4
    
    @connect = (port, host, callback) ->
        new Tarantool Transport.connect port, host, callback
    
    constructor: (@transport) ->
    
    space: (space, mapping) ->
        mapping = new Mapping this, mapping unless mapping instanceof Mapping
        new Space mapping, space

    mapping: (spec) ->
        new Mapping this, spec

    parseBody: (callback) -> (body) ->
        returnCode = body.readUInt32LE 0
        if returnCode > 0
            callback returnCode, body.toString 'utf-8', 4, body.length - 1
        else
            callback returnCode, parse.response body
        return

    request: (type, body, callback) ->
        @transport.request type, body, callback

    
    insert: (space, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        options = compose.int32s space, flags

        request = Buffer.concat [options, compose.tuple tuple]
        @request REQUEST_TYPE.insert, request, @parseBody callback
    
    select: (space, tuples, index, offset, limit, callback) ->
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
        
        options = compose.int32s space, index, offset, limit, tuples.length
        buffers = tuples.map compose.tuple
        buffers.unshift options

        request = Buffer.concat buffers
        @request REQUEST_TYPE.select, request, @parseBody callback
    
    update: (space, tuple, operations, flags, callback) ->
        if flags is undefined
            callback = operations
            operations = DEFAULT_OPERATIONS
            flags = DEFAULT_FLAGS
        else if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        options = compose.int32s space, flags
        tuple = compose.tuple tuple
        count = compose.int32s operations.length
        operations = operations.map compose.operation
        operations.unshift count
        operations.unshift tuple
        operations.unshift options

        request = Buffer.concat operations
        @request REQUEST_TYPE.update, request, @parseBody callback
    
    delete: (space, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        options = compose.int32s space, flags

        request = Buffer.concat [options, compose.tuple tuple]
        @request REQUEST_TYPE.delete, request, @parseBody callback
    
    call: (proc, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        flags = compose.int32s flags
        proc = compose.stringField proc
        tuple = compose.tuple args

        request = Buffer.concat [flags, proc, tuple]
        @request REQUEST_TYPE.call, request, @parseBody callback
    
    ping: (callback) ->
        @request REQUEST_TYPE.ping, '', callback
    
module.exports = Tarantool
