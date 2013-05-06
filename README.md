Beta version of [Tarantool](http://tarantool.org) connector for [node.js](http://nodejs.org)

Connector implements tarantool methods: `insert`, `select`, `update`, `delete`, `call` and `ping`.

Connector uses [Transport](https://github.com/devgru/node-tarantool-transport) to compose and parse request and response bodies.

NPM
---

```shell
npm install tarantool
```

How to use
----------


```coffee
tarantool = require 'tarantool'

tarantoolConnection = tarantool.connect 33013, 'localhost', ->
    tarantoolConnection.ping ->
        console.log 'hello, hairy spider'
```

Check current src/test.coffee for examples of usage.

API
---

### new Connector (Transport) -> Connector

Creates Connector using Transport, which can be any object, with `request(type, body, callback)` and `end()` methods.

### Connector.connect (port, host, callback) -> Connector

Creates Connector and incapsulated Transport.

### connector.insert (space, flags, tuple, callback) ->
### connector.select (space, index, offset, limit, count, tuples, callback) ->
### connector.update (space, flags, tuple, operations, callback) ->
### connector.delete (space, flags, tuple, callback) ->
### connector.call (flags, proc, tuple, callback) ->
### connector.ping (callback) ->

- `space`, `flags`, `offset`, `limit`, `count` are Integers
- `tuple` is an Array of Field Values — Strings, Buffers or Integers
- `proc` is a String
- `operations` is an Array of `operation`, each `operation` is either `{ operation: `[`OperationType`](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L273)`, argument: FieldValue}` or `{ operation: 5, argument: { length: FieldValue, offset: FieldValue, string: FieldValue} }`
- `callback` is a Function that is called as `callback (returnCode, body)` where `body` is array of `tuples` or an error string if `returnCode` is non-zero.

### connector.end () ->

Calls [`end()`](http://nodejs.org/api/net.html#net_socket_end_data_encoding) on Socket.

Space
-----

### connector.space (space) -> Space

Returns Space object, that have `insert`, `select`, `update` and `delete` methods, carried with passed `space` argument.


LICENSE
-------

Tarantool Connector for node.js is published under MIT license.
