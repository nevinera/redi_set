require "spec_helper"
require "redis"

RSpec.describe RediSet::Client do
  let(:config) { Hash[foo: :bar] }
  let(:fake_redis) { instance_double(Redis) }
  before { allow(Redis).to receive(:new).and_return(fake_redis) }

  subject(:client) { RediSet::Client.new(redis_config: config) }

  describe "#match" do
    let(:constraints) { Hash[foo: :a, bar: [1, 2]] }
    let(:fake_result) { %w(a b c d e) }
    let(:fake_query) { instance_double(RediSet::Query, execute: fake_result) }

    it "executes the query as intended" do
      expect(RediSet::Query).to receive(:from_hash).with(constraints).and_return(fake_query)
      expect(fake_query).to receive(:execute).with(fake_redis)
      expect(client.match(constraints)).to eq(fake_result)
    end
  end

  describe "#set_all!" do
    let(:ids) { %w(a b c d e) }

    it "invokes the quality correctly" do
      attribute = instance_double(RediSet::Attribute, name: "foo")
      expect(RediSet::Attribute).to receive(:new).with(name: "foo").and_return(attribute)

      quality = instance_double(RediSet::Quality, name: "bar")
      expect(RediSet::Quality).to receive(:new)
        .with(attribute: attribute, name: "bar").and_return(quality)

      expect(quality).to receive(:set_all!).with(fake_redis, ids)

      client.set_all!("foo", "bar", ids)
    end
  end
end
