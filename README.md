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
