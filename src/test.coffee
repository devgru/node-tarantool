host = '127.0.0.1'
port = 33013

Tarantool = require './'

TarantoolTransport = require 'tarantool-transport'
TarantoolComposer = require 'tarantool-composer'

tt = Tarantool.connect 33013, 'localhost', ->
    tt.ping ->
    #tt.select 0, 0, 0, 5, 1, [[5]], ->
    #    console.log arguments
    tt.insert 0, TarantoolComposer.flags.returnTuple, [Math.floor 4294967295 * Math.random()], (returnCode) ->
        console.log arguments
        tt.end()
