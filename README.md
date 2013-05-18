# Tarantool Node.js Connector — high-level [Tarantool](http://tarantool.org) driver.

Connector implements [Tarantool binary protocol](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt) and exposes nice interface to access Tarantool.

Connector uses [Transport](https://github.com/devgru/node-tarantool-transport) to compose and parse request and response headers.

## NPM

```shell
npm install tarantool
```

## Notes on Tarantool Connector

Connector hides most of protocol-related stuff under the hood, still there are things to know about before using it.

Tarantool manages Spaces instead of Tables and Tuples instead of Rows. Numbers are used to identify Spaces.

Connector methods accepts Tuples. Use Mapping or Space objects to get nice interface, which will accept and return Objects.

## Object-to-Tuple binding specification — `spec`

There are three field types: int32, int64 and octet string. **All integers (options, flags, fields, space ids) are unsigned.**

64-bit integers are implemented in two ways:
- `int53` type: a native JS Number limited to 53 bit that can be stored natively without lost of significance.
- `int64` type: accepts and returns `BigNum` objects from [`bignum`](https://github.com/justmoon/node-bignum).

Build `spec` object to map Object and Tuples to each other. Tarantool knows nothing about field names or types and Connector maps them depending on `spec`.

Example of valid `spec`:
```coffee
spec = id: 'int32', name: 'string', customTypeVar: {pack: ((value) -> ...), unpack: ((buffer) -> ...)}
```

We specify three field-related things: order, name and type. `spec` tells Mapping which place should every field take and how to convert it.

In order to use custom type, replace string with object having `pack: (value) -> buffer` and `unpack: (buffer) -> value` methods as in example above.

*Use any string containing '32' to specity int32 type, same for 53 and 64*

## API

### Connection

`tc` stands for Tarantool Connection

```coffee
# create Connection using default Transport
# default port is 33013
tc = Tarantool.connect port, host, callback
# OR create Connection using Transport, any object, with `request(type, body, callback)`
# tc = new Tarantool transport

# make use of connection
tc.insert space, tuple, [flags,] callback
tc.select space, tuples, [index, [offset, [limit,]]] callback
tc.update space, tuple, [operations, [flags,]] callback
tc.delete space, tuple, [flags,] callback
tc.call proc, tuple, [flags,] callback
tc.ping callback

```

- `space`, `flags`, `offset` and `limit` are Integers
- `space` is Space number
- `flags` is optional field, [possible values](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L231) are stored in `Tarantool.flags` in camelCase, e.g. Tarantool.flags.returnTuple
- `offset` and `limit` are optional, use them to specify ammount of returned with select
- `tuples` is an Array of tuples
- `tuple` is an Array of Fields, each Field is Buffer
- `proc` is a String
- `operations` is an Array of `operation`, they are constructed via Mapping or Space methods (see below)
- `callback` is a Function that is called as `callback (returnCode, body)` where `body` is an Array of `tuples` or a Number or an error string if `returnCode` is non-zero.

### Mapping

Use Mapping to access several spaces with similar structure.

Mapping API:
```coffee
# creating mapping with specified spec
mapping = tc.mapping spec

# forgetting about tuples
mapping.insert space, object, [flags,] callback
mapping.select space, objects, [index, [offset, [limit,]]] callback
mapping.update space, object, [operations, [flags,]] callback
mapping.delete space, object, [flags,] callback
mapping.call proc, object, [flags,] callback
```

`callback` will be called as `callback (returnCode, body)` where `body` is an Array of *Objects* or a Number or an error string if `returnCode` is non-zero.

```coffee
# creating operations list — see below
mapping.assign argument
mapping.add argument
mapping.and argument
mapping.xor argument
mapping.or argument
mapping.delete argument
mapping.insertBefore argument
mapping.splice spliceArgument
```

`spliceArgument` is a Hash (Object) with three keys: `string` (String), `offset` (Number) and `length` (Number).

`argument` is a Hash (Object) with single key.


### Space

Space incapsulates Mapping and space number to give you shortest API:

```coffee
# creating Space with spec
space = tc.space space, spec
# OR with mapping
# mapping = tc.mapping spec
# space = tc.space space, mapping

space.insert object, [flags,] callback
space.select objects, [index, [offset, [limit,]]], callback
space.update object, [operations, [flags,]] callback
space.delete object, [flags,] callback

# creating operations list
space.assign argument
space.add argument
space.and argument
space.xor argument
space.or argument
space.delete argument
space.insertBefore argument
space.splice spliceArgument
```

### Operations

Tarantool's update deals with "operations" — atomic field actions.

Here's an example:

```coffee
spec = id: 'i32', name: 'string', winner: 'i32'
userSpace = tc.space 2, spec
operations = [
    userSpace.or winner: 1
    userSpace.splice name: offset: 0, length: 0, string: '[Winner] '
]
userSpace.update { id: userId }, operations, ->
    console.log 'winner now has [Winner] tag before his name'
```

### TODO
- check if Buffer.concat is fast enough, if it is slow - replace with array of buffers, concat only before transport.request
- check argument type in operations
- write about Tarantool keys and multi-object select
- more tests

### Bugs and issues
Bug reports are welcome :)

### LICENSE
Tarantool Connector for node.js is published under MIT license.
