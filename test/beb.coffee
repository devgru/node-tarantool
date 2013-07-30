beb = require '../src/beb'

exports['encode'] = (test) ->
    test.equalBuffer = (b1, b2) ->
        @equal b1.toString('hex'), b2.toString('hex')
    test.equalBuffer (new Buffer [0x80 | 1, 0]), beb.encode 128
    test.equalBuffer (new Buffer [0x80 | 1, 1]), beb.encode 129
    do test.done
    
exports['fuzz'] = (test) ->
    for i in [0...(1<<15)] by 1<<5
        test.equal i, beb.decode(beb.encode(i)).value
    do test.done

