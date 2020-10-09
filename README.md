## What Is It?

RediSet is a redis-backed library that makes it easy to find members within a population
satisfying sets of attribute constraints. Given information about a large population of
cats for example, we could quickly find the set of cats that are male, calico, short-hair,
and live in Oregon.

## But Why?

This problem is easy to solve for most situations - if you just need to generate a list,
you can process a csv with a very simple script or a perl one-liner. If you only have to
handle a few thousand cats, any database will do the trick - table-scans aren't *that*
costly.

But if you have millions of records, they receive frequent updates (because some of your
attributes are mutable), records are added and removed on a regular basis, and you need to
perform a continuous stream of varied requests, you may find that your queries aren't scaling
well - a *set* querying engine is one straightforward solution to that problem.

With hash-backed sets, we can perform intersections very quickly - if we simply model every
attribute as multiple sets (the set of male cats and the set of female cats, for example),
we can easily construct lists of records that match complex constraints with pure set union
and intersection operations. And Redis has that data structure ready to go!

## Usage

```ruby
require 'redis'
require 'redi_set'

redis = Redis.new(ENV['REDIS_URL'])
client = RediSet::Client.new(redis: redis)

# Get the data from elsewhere - csv, database, etc
# and then write it into redis in bulk.
client.set_all!(:color, :red, %w(a b c d e))
client.set_all!(:color, :blue, %w(a p j k))
client.set_all!(:size, :large, %w(a m n 1))
client.set_all!(:size, :small, %w(p j d e))

# Now we can query it by listing for each attribute which values are allowed.
# We will union the allowed sets for each attribute, and then intersect the allowed sets
# across attributes.
client.match(color: :red)                 # gives %w(a b c d e)
client.match(color: [:red, :blue])        # gives %w(a b c d e p j k)
client.match(color: :red, size: :small)   # gives %w(d e)

# And we can update data for an individual entity like this:
client.set_details!(:a, {
  color: { red: false, blue: false, green: true },
  size: { small: false, large: true, enormous: true },
})
```
