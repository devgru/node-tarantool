Beta version of [Tarantool](http://tarantool.org) connector for [node.js](http://nodejs.org).

Connector implements [Tarantool binary protocol](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt) and allows you to use nice interface to access Tarantool.

Connector uses [Transport](https://github.com/devgru/node-tarantool-transport) to compose and parse request and response headers.

## NPM

```shell
npm install tarantool
```

## Notes on Tarantool Connector

Connector tries to be useful hiding most of Tarantool protocol related stuff under the hood.

There are no Tables and Rows in Tarantool, there are Spaces and Tuples instead, with numbers instead of names.

Raw Connector methods deal with Tuples, each is Array of Buffers. You should use Space methods and `spec` object (see below) instead to get nicer interface, which will map field order and types to object fields for you.

Tarantool stores data in fields, field type is either int32, int64 or octet string. **All integers in options or fields are unsigned.**

64-bit integers are not implemented yet, they can not be stored in V8 natively without lost of significance. Maybe I will implement it with bignum by fullmoon or javascript-bignum.

We can use octet string to store Strings, Buffers and Objects (as JSON).

## Object to Tuple binding specification — `spec`

There are following field types you can use as `spec` values:
- int32 - unsigned 32-bit integer
- string - utf-8 encoded string
- buffer - passed as is
- object - mapped to string via `JSON.stringify`/`JSON.parse`
- int64 - **not implemented yet**

Example of valid `spec`:
```coffee
spec = id: 'int32', name: 'string'
```

Here we specify three field-related things: order, name and type. Order-Name two-way binding allows to map fields, and Name-Type binding allows to transform values to Buffer and back.

If you want to use any other type or override default you should implement your own Transformer (see below).

*int32, i32, or just 32 can be used to specify int32 type, same for 64*

## API

### Connection

`tc` stands for Tarantool Connection

```coffee
# create Connection using Transport, any object, with `request(type, body, callback)`
tc = new Tarantool transport
# OR use create default Transport
tc = Tarantool.connect port, host, callback

# now we can use connection
tc.insert space, tuple, [flags,] callback
tc.select space, tuples, [index, [offset, [limit,]]] callback
tc.update space, tuple, [operations, [flags,]] callback
tc.delete space, tuple, [flags,] callback
tc.call proc, tuple, [flags,] callback
tc.ping callback

# please, don't generate tuples yourself, use transform:
tuple = tc.transform object, spec [, transformers]
```

- `space`, `flags`, `offset` and `limit` are Integers
- `space` is Space number
- `flags` is optinal field, [possible values](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L231) are stored in `Tarantool.flags` in camelCase, e.g. Tarantool.flags.returnTuple
- `offset` and `limit` are optional, use them to specify ammount of returned with select
- `tuples` is an Array of tuples
- `tuple` is an Array of Fields, each Field is Buffer
- `proc` is a String
- `operations` are constructed via space methods (see below)
- `callback` is a Function that is called as `callback (returnCode, body)` where `body` is array of `tuples` or an error string if `returnCode` is non-zero.
- `transformers` is Hash (Object), each element is Transformer, name is type name
- `transformer` is an Object with `pack` and `unpack` methods.
- `spec` is object, its keys are field names, values are types, and order is order of fields in tuple

It's recommended to use Space, it will transform objects for you.

### Space

```coffee
# creating Space with known spec, and, maybe additional transformations
space = tc.space space, spec[, transformers]

space.insert object, [flags,] callback
space.select objects, [index, [offset, [limit,]]], callback
space.update object, [operations, [flags,]] callback
space.delete object, [flags,] callback

# if we need to create operations list:
space.assign argument
space.add argument
space.and argument
space.xor argument
space.or argument
space.delete argument
space.insertBefore argument
space.splice spliceArgument
```

`spliceArgument` is a Hash (Object) with three keys: `string` (String), `offset` (Number) and `length` (Number)

`argument` is a Hash (Object) with single key, e.g.:

```coffee
spec = id: 'i32', name: 'string', winner: 'i32'
userSpace = tc.space 2, spec
operations = [
    userSpace.or winner: 1
    userSpace.splice name: offset: 0, length: 0, string: '[Winner] '
]
userSpace.update { id: userId }, operations, ->
    console.log 'winner updated'
```

### TODO
- check if Buffer.concat is fast enough, if it is slow - replace with array of buffers, concat only before transport.request
- more tests
- research int64 transformer implementation

### Bugs and issues
Bug reports are welcome :)

### LICENSE
Tarantool Connector for node.js is published under MIT license.
