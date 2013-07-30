# this file fixes LEB128 behaviour to be compatible with Tarantool

leb = require 'leb'

fix = (result) ->
    len = result.length
    # we have to reverse it
    reversed = new Buffer len
    for i in [0...len]
        reversed[i] = result[len - 1 - i]
    
    # and toggle #7 bit in first and last bytes
    reversed[0] ^= 0x80
    reversed[len - 1] ^= 0x80
    
    reversed

encode = (data) -> fix leb.encodeUInt32 data

decode = (buf, pos = 0) ->
    # we have to know what amount of bytes to read
    temp = leb.decodeUInt32 buf, pos

    # then slice the buffer, remembering position
    buf = buf.slice pos, temp.nextIndex
    result = leb.decodeUInt32 fix buf

    # fix the position
    result.nextIndex += pos
    result

module.exports =
    encodeUInt32: encode
    decodeUInt32: decode
