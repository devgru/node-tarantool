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
        space.insert first: rnd()*rnd()*rnd()+rnd()*rnd()+rnd(), Tarantool.flags.returnTuple, (returnCode) -> console.log arguments
        space.select [{first: 0}], (code, objects) ->
            console.log 'hello'

        userId = rnd()*rnd()*rnd()+rnd()*rnd()+rnd()
        spec = id: 'i32', name: 'string', winner: 'i32'
        userSpace = tt.space 0, spec
        operations = [
            userSpace.or winner: 1
            userSpace.splice name: offset: 0, length: 0, string: '[Winner] '
        ]
        userSpace.insert {id: z=userId, winner: 0, name: 'asd'}, (err, inserted) ->
            console.log 'inserted', z

            userSpace.update { id: userId }, operations, ->
                console.log 'winner updated'
                userSpace.select [{id: userId}], (code, users) ->
                    console.log users
