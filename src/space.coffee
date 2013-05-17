class Space
    constructor: (@mapping, @space) ->
    
    # # space methods # #
    
    insert: (object, flags, callback) ->
        @mapping.insert @space, object, flags, callback
    
    select: (objects, index, offset, limit, callback) ->
        @mapping.select @space, objects, index, offset, limit, callback
    
    update: (object, operations, flags, callback) ->
        @mapping.update @space, object, operations, flags, callback
    
    delete: (object, flags, callback) ->
        @mapping.delete @space, object, flags, callback

    # # update operations # #

    assign: (object) -> @mapping.assing object
    add: (object) -> @mapping.add object
    and: (object) -> @mapping.and object
    xor: (object) -> @mapping.xor object
    or: (object) ->  @mapping.or object
    delete: (object) -> @mapping.delete object
    insertBefore: (object) -> @mapping.insertBefore object

    splice: (object) -> @mapping.splice object

module.exports = Space
