Tarantool = require '../src'

exports['connect'] = (test) ->
    test.expect 1
    test.doesNotThrow ->
        Tarantool.connect 33013, 'localhost', ->
            test.done()

exports['ping'] = (test) ->
    test.expect 1
    test.doesNotThrow ->
        tc = Tarantool.connect 33013, 'localhost', ->
            tc.ping -> test.done()

exports['insert and select'] = (test) ->
    test.expect 8
    tc = Tarantool.connect 33013, 'localhost', ->
        rnd = -> Math.floor (Math.random() * 4294967295)
        
        mapping = tc.mapping first: '32', second: '32'
        space = tc.space 0, mapping
        objectToInsert = {first: rnd(), second: rnd()}
        console.log mapping.packObject object
        space.insert objectToInsert, Tarantool.flags.returnTuple, (code, objects) ->
            test.ok objects instanceof Array, 'array is returned'
            test.ok objects.length is 1, 'only one tuple was returned'
            console.log insertedObject = objects[0]
            test.deepEqual insertedObject, objectToInsert, 'it is like the one we inserted'
            space.insert objectToInsert, (code, objects) ->
                test.ok objects is 1

                space.select [{first: insertedObject.first}], (code, objects) ->
                    test.ok objects instanceof Array, 'array is returned'
                    test.ok objects.length is 1, 'only one tuple was returned'
                    selectedObject = objects[0]
                    test.deepEqual selectedObject, objectToInsert, 'it is like the one we inserted'
                    space.select [{first: insertedObject.first}], 0, 1, 0, (code, objects) ->
                        test.ok objects is 0, 'no tuples due to offset'
                        test.done()


exports['insert and select'] = (test) ->
    test.expect 8
    tc = Tarantool.connect 33013, 'localhost', ->
        rnd = -> Math.floor (Math.random() * 4294967295)
        
        mapping = tc.mapping first: '32', second: '32'
        space = tc.space 0, mapping
        objectToInsert = {first: rnd(), second: rnd()}
        space.insert objectToInsert, Tarantool.flags.returnTuple, (code, objects) ->
            test.ok objects instanceof Array, 'array is returned'
            test.ok objects.length is 1, 'only one tuple was returned'
            insertedObject = objects[0]
            test.deepEqual insertedObject, objectToInsert, 'it is like the one we inserted'
            space.insert objectToInsert, (code, objects) ->
                test.ok objects is 1

                space.select [{first: insertedObject.first}], (code, objects) ->
                    test.ok objects instanceof Array, 'array is returned'
                    test.ok objects.length is 1, 'only one tuple was returned'
                    selectedObject = objects[0]
                    test.deepEqual selectedObject, objectToInsert, 'it is like the one we inserted'
                    space.select [{first: insertedObject.first}], 0, 1, 0, (code, objects) ->
                        test.ok objects is 0, 'no tuples due to offset'
                        test.done()

