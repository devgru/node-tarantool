Transport = require 'tarantool-transport'
Composer = require './composer'
Space = require './space'
Mapping = require './mapping'

parse = require './parse'

DEFAULT_OFFSET = 0
DEFAULT_OPERATIONS = []
DEFAULT_FLAGS = 0
DEFAULT_INDEX = 0
DEFAULT_LIMIT = 4294967295

class Tarantool
    @flags =
        none       : 0
        returnTuple: 1
        add        : 2
        replace    : 4
    
    @connect: (port, host, callback) ->
        new Tarantool Transport.connect port, host, callback
    
    constructor: (transport) ->
        @composer = new Composer transport
    
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
    
    insert: (space, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        @composer.insert space, tuple, flags, @parseBody callback
    
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

        @composer.select space, tuples, index, offset, limit, @parseBody callback
    
    update: (space, tuple, operations, flags, callback) ->
        if flags is undefined
            callback = operations
            operations = DEFAULT_OPERATIONS
            flags = DEFAULT_FLAGS
        else if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        @composer.update space, tuple, operations, flags, @parseBody callback
    
    delete: (space, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        @composer.delete space, tuple, flags, @parseBody callback
    
    call: (proc, tuple, flags, callback) ->
        if callback is undefined
            callback = flags
            flags = DEFAULT_FLAGS

        @composer.call proc, tuple, flags, @parseBody callback
    
    ping: (callback) ->
        @composer.ping callback
    
module.exports = Tarantool
