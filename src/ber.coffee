###
BEB128 implementation. Tarantool uses BEB128 and calls it LEB128 somewhy.

Big-endian base-128 uses 7 bits for value and most significant bit (MSB) for flag
If flag is 1 — there is more bytes, continue reading.
So, 127 is 0x7f, 128 is 0x81 0x00, 129 is 0x81 0x01 and so on.
###

encode = (value) ->
    bytes = []

    bytes.push value >> 28 | 0x80 if value >= 1 << 28
    bytes.push value >> 21 | 0x80 if value >= 1 << 21
    bytes.push value >> 14 | 0x80 if value >= 1 << 14
    bytes.push value >>  7 | 0x80 if value >= 1 <<  7
    bytes.push value & 0x7F

    new Buffer bytes

decode = (buffer, position = 0) ->
    value = 0
    loop # stops after reading byte with MSB=0
        byte = buffer[position++]
        value = (value << 7) + (byte & 0x7F)
        break unless byte & 0x80
    
    value: value
    nextIndex: position

module.exports =
    encode: encode
    decode: decode
