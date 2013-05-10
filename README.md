Beta version of [Tarantool](http://tarantool.org) connector for [node.js](http://nodejs.org)

Connector implements tarantool methods: `insert`, `select`, `update`, `delete`, `call` and `ping`.

Connector uses [Transport](https://github.com/devgru/node-tarantool-transport) to compose and parse request and response headers.
Connector composes all arguments into binary Tarantool request.

NPM
---

```shell
npm install tarantool
```

How to use
----------


```coffee
tarantool = require 'tarantool'

tc = tarantool.connect 33013, 'localhost', ->
    tc.ping ->
        console.log 'hello, hairy spider'
```

Check current src/test.coffee for examples of usage.

API
---

### new Connector (Transport) -> Connector

Creates Connector using Transport, which can be any object, with `request(type, body, callback)` method.

### Connector.connect (port, host, callback) -> Connector

Creates Connector and incapsulated Transport.

### connector.insert (space, tuple, [flags,] callback) ->
### connector.select (space, tuples, [index, [offset, [limit,]]] callback) ->
### connector.update (space, tuple, [operations, [flags,]] callback) ->
### connector.delete (space, tuple, [flags,] callback) ->
### connector.call (proc, tuple, [flags,] callback) ->
### connector.call (proc, object, spec, [transformers, [flags,]] callback) ->
### connector.ping (callback) ->

- `space`, `flags`, `offset`, `limit`, `count` are Integers
- `tuple` is an Array of Field Values — Strings, Buffers or Integers
- `proc` is a String
- `operations` is an Array of `operation`, each `operation` is either `{ operation: `[`OperationType`](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L273)`, argument: FieldValue}` or `{ operation: 5, argument: { length: FieldValue, offset: FieldValue, string: FieldValue} }`
- `callback` is a Function that is called as `callback (returnCode, body)` where `body` is array of `tuples` or an error string if `returnCode` is non-zero.
- `transformers` is Hash (Object), each element is Object with `pack` and `unpack` methods. If you are using default types (see below) you don't have to specify custom transformers.
- `spec` is object, its keys are field names, values are types:
```coffee
usersSpec = id: 'int32', name: 'string', meta: 'object'
users = tc.space 0, usersSpec
```

Space
-----

### connector.space (space, spec[, transformers]) -> Space

Returns Space object, which deals with objects, incapsulating tuples.

### space.insert (object, [flags,] callback) ->
### space.select (objects, [index, [offset, [limit,]]], callback) ->
### space.update (object, [operations, [flags,]] callback) ->
### space.delete (object, [flags,] callback) ->

Types
-----

there are following types of field:
- int32 - unsigned 32-bit integer
- string - utf-8 encoded string
- buffer - passed as is
- object - transformed to string by `JSON.stringify`/`JSON.parse`
- int64 - **not implemented yet**

TODO
----
- check if Buffer.concat is fast enough, if it is slow - replace with array of buffers, concat only before transport.request
- more tests
- splice operations implementation
- research int64 transformer implementation

LICENSE
-------

Tarantool Connector for node.js is published under MIT license.
