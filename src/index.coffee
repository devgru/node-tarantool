Transport = require 'tarantool-transport'
Composer = require './composer'
Space = require './space'

parse = require './parse'

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
    
    
    parseBody: (callback) -> (header, body) ->
        returnCode = body.readUInt32LE 0
        if returnCode > 0
            callback returnCode, header, body.toString 'utf-8', 4
        else
            tuples = parse.response body
            callback returnCode, header, tuples
        return
    
    insert: (space, flags, tuple, callback) ->
        @composer.insert space, flags, tuple, @parseBody callback
    
    select: (space, index, offset, limit, count, tuples, callback) ->
        @composer.select space, index, offset, limit, count, tuples, @parseBody callback
    
    update: (space, flags, tuple, operations, callback) ->
        @composer.update space, flags, tuple, operations, @parseBody callback
    
    delete: (space, flags, tuple, callback) ->
        @composer.delete space, flags, tuple, @parseBody callback
    
    call: (flags, proc, tuple, callback) ->
        @composer.call flags, proc, tuple, @parseBody callback
    
    ping: (callback) ->
        @composer.ping callback
    
    end: () ->
        @transport.end()
    
module.exports = Tarantool
