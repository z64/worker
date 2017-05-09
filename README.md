# worker

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  worker:
    github: z64/worker
```

## Usage

```crystal
require "worker"

# Create a pool of 5 workers that converts Int32s to Strings
pool = Worker::Pool(Int32, String).new(5) { |input| input.to_s }

# Handle some input
puts pool.handle(5) #=> {Ok, 5, "5"}
```

TODO: Write usage instructions here

## Contributors

- [z64](https://github.com/z64) Zac Nowicki - creator, maintainer
