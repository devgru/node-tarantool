class Space
    constructor: (@connector, @space) ->
    
    insert: (flags, tuple, callback) ->
        @connector.insert @space, flags, tuple, callback
    
    select: (index, offset, limit, count, tuples, callback) ->
        @connector.select @space, index, offset, limit, count, tuples, callback
    
    update: (flags, tuple, operations, callback) ->
        @connector.update @space, flags, tuple, operations, callback
    
    delete: (flags, tuple, callback) ->
        @connector.delete @space, flags, tuple, callback

module.exports = Space
