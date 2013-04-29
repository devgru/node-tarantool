host = '127.0.0.1'
port = 33013

Tarantool = require './'
TarantoolTransport = require 'tarantool-transport'

tt = Tarantool.connect 33013, 'localhost', ->
    tt.ping ->
    
        tt.socket.end()

