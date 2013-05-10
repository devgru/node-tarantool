host = '127.0.0.1'
port = 33013

Tarantool = require './'

TarantoolTransport = require 'tarantool-transport'

tt = Tarantool.connect 33013, 'localhost', ->
    # maybe the fact of connection marks that tarantool is up, but let's check with ping
    tt.ping ->
        space = tt.space 0, first: 'i32', second: 'i32', third: 'object'
        #space.select [first: 5], ->  console.log arguments
        rnd = -> Math.floor 255 * Math.random()
        space.insert first: rnd()*rnd()+rnd(), Tarantool.flags.returnTuple, (returnCode) -> console.log arguments
        space.select [{first: 0}], (code, objects) ->
            console.log 'hello'