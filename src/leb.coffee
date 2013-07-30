# this file fixes LEB128 behaviour to be compatible with Tarantool

leb = require 'leb'

fix = (fn) ->
    (data) ->
        result = fn data
        len = result.length

        # we have to reverse result
        reversed = new Buffer len
        for i in [0...len]
            reversed[i] = result[len - 1 - i]

        # and toggle #7 bit in first and last bytes
        reversed[0] ^= 0x80
        reversed[len - 1] ^= 0x80

        reversed

module.exports =
    encodeUInt32: fix leb.encodeUInt32
    decodeUInt32: fix leb.decodeUInt32
