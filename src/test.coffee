host = '127.0.0.1'
port = 33013

Tarantool = require './'
concat = Buffer.concat
counter = 0
Buffer.concat = ->
    console.log (new Error().stack.split('\n').slice 2, 4), arguments
    concat.apply Buffer, arguments

TarantoolTransport = require 'tarantool-transport'

bignum = require 'bignum'

tt = Tarantool.connect 33013, 'localhost', ->
    spec = test: '64'
    # tt.transform {test: bignum '18446744073709551615'}, spec
    
    # maybe the fact of connection marks that tarantool is up, but let's check with ping
    tt.ping ->
        counter = 0
        space = tt.space 0, first: 'i32', second: 'i32', third: 'object'
        #space.select [first: 5], ->  console.log arguments
        rnd = -> Math.floor 255 * Math.random()
        space.insert first: rnd()*rnd()*rnd()+rnd()*rnd()+rnd(), Tarantool.flags.returnTuple, (returnCode) ->
            counter = 0
            console.log arguments
            space.select [{first: 0}], (code, objects) ->
                counter = 0
                console.log 'hello'

                userId = rnd()*rnd()*rnd()+rnd()*rnd()+rnd()
                spec = id: 'i32', name: 'string', winner: 'i32'
                userSpace = tt.space 0, spec
                operations = [
                    userSpace.or winner: 1
                    userSpace.splice name: offset: 0, length: 0, string: '[Winner] '
                ]
                userSpace.insert {id: z=userId, winner: 0, name: 'asd'}, (err, inserted) ->
                    counter = 0
                    console.log 'inserted', z

                    userSpace.update { id: userId }, operations, ->
                        counter = 0
                        console.log 'winner updated'
                        userSpace.select [{id: userId}], (code, users) ->
                            counter = 0
                            console.log users
