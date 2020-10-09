require 'spec_helper'

RSpec.describe RediSet do
  let(:redis) { MockRedis.new }
  let(:client) { RediSet::Client.new(redis: redis) }

  it "acts as we expect" do
    # initial setup
    client.set_all!(:foo, :a, [1, 5, 6, 9])
    client.set_all!(:foo, :b, [2, 15, 21, 401])
    client.set_all!(:foo, :c, [4, 6])

    client.set_all!(:bar, :x, %w(1 2 3))
    client.set_all!(:bar, :y, %w(4 5 6))
    client.set_all!(:bar, :z, %w(7 8 9))

    client.set_all!(:baz, :one, [4, 12, 401])
    client.set_all!(:baz, :two, [4, 5, 7, 8, 21])

    # run some queries against that data
    expect(client.match(foo: :a)).to contain_exactly("1", "5", "6", "9")
    expect(client.match(baz: :one, foo: :b)).to contain_exactly("401")
    expect(client.match(foo: [:a, :b], bar: :x)).to contain_exactly("1", "2")
    expect(client.match(bar: [:x, :y, :z])).to match_array(%w(1 2 3 4 5 6 7 8 9))
    expect(client.match(nope: :never)).to be_empty
    expect(client.match(bar: :k)).to be_empty

    # update entity 3
    client.set_details!(3, {
      foo: { a: true, b: false, c: true },
      bar: { x: false, y: true, z: false },
      baz: { one: false, two: true },
    })

    # Show that 3 was added to foo:a, bar:y, and baz:two
    # 1 3 5 6 9  N  3 4 5 6  N  3 4 5 7 8 21  ->  3 5
    expect(client.match(foo: :a, bar: :y, baz: :two)).to match_array(%w(3 5))

    # Show that 3 has been removed from bar:x
    # 1 3 5 6 9  N  1 2  N  3 4 5 7 8 21  ->  EMPTY
    expect(client.match(foo: :a, bar: :x, baz: :two)).to be_empty

    # remove entity 4 from everything
    client.set_details!(4, {
      foo: { a: false, b: false, c: false },
      bar: { x: false, y: false, z: false },
      baz: { one: false, two: false },
    })

    # confirm it's not listed in any of the attributes now
    expect(client.match(foo: [:a, :b, :c])).not_to include("4")
    expect(client.match(bar: [:x, :y, :z])).not_to include("4")
    expect(client.match(baz: [:one, :two])).not_to include("4")
  end
end
