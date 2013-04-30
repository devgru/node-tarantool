leb = require 'leb'

module.exports = parse =
    response: (body) ->
        count = body.readUInt32LE 0
        bytesRead = 4
        tuples = []
        while count > 0
            size = body.readUInt32LE bytesRead
            bytesRead += 4
            tuple = body.slice bytesRead, bytesRead + size + 4
            bytesRead += 4 + size
            tuples.push parse.tuple tuple
            count--
        
        return tuples
    
    tuple: (tuple) ->
        cardinality = tuple.readUInt32LE 0
        count = cardinality
        tuple = tuple.slice 4, tuple.length
        fields = []
        while count > 0
            sizeLeb = leb.decodeUInt32 tuple
            bytesRead = sizeLeb.nextIndex
            size = sizeLeb.value
            fields.push tuple.slice bytesRead, bytesRead + size
            tuple = tuple.slice bytesRead + size, tuple.length
            count--
        
        return fields
