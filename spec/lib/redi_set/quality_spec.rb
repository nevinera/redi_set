require "spec_helper"
require "redis"

RSpec.describe RediSet::Quality do
  let(:attribute) { RediSet::Attribute.new(name: "foo") }
  let(:name) { "bar" }
  let(:quality) { described_class.new(attribute: attribute, name: name) }

  describe "#key" do
    subject(:key) { quality.key }
    before { allow(RediSet).to receive(:prefix).and_return("prefixinator") }
    it { is_expected.to eq("prefixinator.attr:foo:bar") }
  end

  describe "#set_all!" do
    let(:redis) { instance_double(Redis, del: :OK, sadd: :OK) }
    let(:ids) { %w(a b c d e) }
    before { allow(redis).to receive(:multi).and_yield.and_return([:OK, :OK]) }

    it "performs the intended operations on redis" do
      expect(quality.set_all!(redis, ids)).to eq([:OK, :OK])
      expect(redis).to have_received(:multi)
      expect(redis).to have_received(:del).with(quality.key)
      expect(redis).to have_received(:sadd).with(quality.key, ids)
    end
  end
end
