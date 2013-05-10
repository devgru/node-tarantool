Beta version of [Tarantool](http://tarantool.org) connector for [node.js](http://nodejs.org)

Connector implements tarantool methods: `insert`, `select`, `update`, `delete`, `call` and `ping`.

Connector uses [Transport](https://github.com/devgru/node-tarantool-transport) to compose and parse request and response headers.
Connector composes all arguments into binary Tarantool request.

## NPM

```shell
npm install tarantool
```

## How to use

```coffee
Tarantool = require 'tarantool'

tc = Tarantool.connect 33013, 'localhost', ->
    tc.ping ->
        console.log 'hello, hairy spider'
```

Check current test/*.coffee for examples of usage.

## API

### Creating Connector

`tc` stands for Tarantool Connection

```coffee
# create Connection using Transport, any object, with `request(type, body, callback)`
tc = new Tarantool (transport)
# OR use create default Transport
tc = Tarantool.connect (port, host, callback)

# now we can use connection

tc.insert (space, tuple, [flags,] callback)
tc.select (space, tuples, [index, [offset, [limit,]]] callback)
tc.update (space, tuple, [operations, [flags,]] callback)
tc.delete (space, tuple, [flags,] callback)
tc.call (proc, tuple, [flags,] callback)
tc.call (proc, object, spec, [transformers, [flags,]] callback)
tc.ping (callback)
```

- `space`, `flags`, `offset`, `limit`, `count` are Integers
- `tuple` is an Array of Field Values — Strings, Buffers or Integers
- `proc` is a String
- `operations` are constructed via space methods (see below)
- `callback` is a Function that is called as `callback (returnCode, body)` where `body` is array of `tuples` or an error string if `returnCode` is non-zero.
- `transformers` is Hash (Object), each element is Object with `pack` and `unpack` methods. If you are using default types (see below) you don't have to specify custom transformers.
- `spec` is object, its keys are field names, values are types:
```coffee
usersSpec = id: 'int32', name: 'string', meta: 'object'
users = tc.space 0, usersSpec
```

Specs are important for `update` and `call`, they specify tuple to array binding.

### Space

```coffee
# creating Space with known spec, and, maybe additional transformations
tc.space (space, spec[, transformers]) -> Space

space.insert (object, [flags,] callback)
space.select (objects, [index, [offset, [limit,]]], callback)
space.update (object, [operations, [flags,]] callback)
space.delete (object, [flags,] callback)

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

### Types

there are following field types:
- int32 - unsigned 32-bit integer
- string - utf-8 encoded string
- buffer - passed as is
- object - mapped to string via `JSON.stringify`/`JSON.parse`
- int64 - **not implemented yet**

*int32, i32, or just 32 can be used to specify int32 type, same for 64*

### TODO
- check if Buffer.concat is fast enough, if it is slow - replace with array of buffers, concat only before transport.request
- more tests
- research int64 transformer implementation

### LICENSE

Tarantool Connector for node.js is published under MIT license.
