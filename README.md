Alpha version of Tarantool connector for node.js

Check current src/test.coffee for examples of usage.

```coffee
tarantool = require 'tarantool'

tc = tarantool.connect 33013, 'localhost' ->
    tc.ping ->
        console.log 'hello, hairy spider'
```
