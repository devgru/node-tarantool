host = '127.0.0.1'
port = 33013

Tarantool = require './'

TarantoolTransport = require 'tarantool-transport'

tt = Tarantool.connect 33013, 'localhost', ->
    # maybe the fact of connection marks that tarantool is up, but let's check with ping
    tt.ping ->
        space = tt.space 0
        space.select 0, 0, 5, 1, [[5]], ->
            console.log arguments
        space.insert Tarantool.flags.returnTuple, [Math.floor 4294967295 * Math.random()], (returnCode) ->
            console.log arguments
        tt.end()
