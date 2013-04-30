transport = require 'tarantool-transport'
composer = require 'tarantool-composer'

parse = require './parse'

class Tarantool
    @connect: (port, host, callback) ->
        new Tarantool composer.connect port, host, callback
    
    constructor: (@composer) ->
    
    parseBody: (callback) -> (returnCode, header, body) ->
        tuples = parse.response body
        callback returnCode, header, tuples
        
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
        @composer.end()
    
module.exports = Tarantool
