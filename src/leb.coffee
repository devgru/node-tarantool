encodeLeb = (value) ->
    bytes = []

    if value >= (1 << 7)
        if value >= (1 << 14)
            if value >= (1 << 21)
                if value >= (1 << 28)
                    bytes.push (value >> 28) | 0x80
                bytes.push (value >> 21) | 0x80
            bytes.push (value >> 14) | 0x80
        bytes.push (value >> 7) | 0x80
    bytes.push (value) & 0x7F

    new Buffer bytes

module.exports =
    encodeUInt32: encodeLeb
