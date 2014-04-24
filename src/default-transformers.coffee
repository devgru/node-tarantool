bignum = require 'bignum' # i64
int53 = require 'int53' # i53

module.exports =
    string:
        pack: (value) -> new Buffer value, 'utf-8'
        unpack: (buffer) -> buffer.toString 'utf-8'
    buffer:
        pack: (value) -> value
        unpack: (buffer) -> buffer
    object:
        pack: (value) -> new Buffer JSON.stringify(value), 'utf-8'
        unpack: (buffer) -> JSON.parse buffer.toString 'utf-8'
    32:
        pack: (value) ->
            field = new Buffer 4
            field.writeUInt32LE value, 0
            field
        unpack: (buffer) -> buffer.readUInt32LE 0
    53:
        pack: (value) ->
            field = new Buffer 8
            int53.writeUInt64LE value, field, 0
            field
        unpack: (buffer) -> int53.readUInt64LE buffer, 0
    64:
        pack: (value) -> value.toBuffer size: 8, endian: 'little'
        unpack: (buffer) -> bignum.fromBuffer size: 8, endian: 'little'
