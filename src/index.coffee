transport = require 'tarantool-transport'

class Tarantool
    @connect: (port, host, callback) ->
        new Tarantool transport.connect port, host, callback

    constructor: (@transport) ->
    
    ping: (callback) ->
        @request transport.requestTypes.ping, '', callback

    request: (type, body, callback) ->
        @transport.request type, body, callback

    end: () ->
        @transport.socket.end()
    
module.exports = Tarantool
