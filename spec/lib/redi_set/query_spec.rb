require "spec_helper"
require "redis"

RSpec.describe RediSet::Query do
  describe ".from_hash" do
    subject(:from_hash) { RediSet::Query.from_hash(hash) }

    context "for a simple hash" do
      let(:hash) { Hash[a: [1], b: [2]] }

      it "builds the expected query" do
        expect(from_hash.constraints.map(&:attribute)).to eq([:a, :b])
        expect(from_hash.constraints.map(&:values)).to eq([[1], [2]])
      end
    end

    context "for a complex hash" do
      let(:hash) { Hash[a: [1, :b], b: [3], c: "4", d: (1..4)] }

      it "builds the expected query" do
        expect(from_hash.constraints.map(&:attribute)).to eq([:a, :b, :c, :d])
        expect(from_hash.constraints.map(&:values)).to eq([[1, :b], [3], ["4"], [1, 2, 3, 4]])
      end
    end
  end

  describe "#execute" do
    let(:con_foo) do
      instance_double(RediSet::Constraint,
                      requires_union?: true,
                      store_union: true,
                      intersection_key: "key_foo")
    end

    let(:con_bar) do
      instance_double(RediSet::Constraint,
                      requires_union?: false,
                      store_union: true,
                      intersection_key: "key_bar")
    end

    let(:constraints) { [con_foo, con_bar] }
    subject(:query) { RediSet::Query.new(constraints) }

    let(:results) { ["x", "y", "z"] }
    let(:redis) { instance_double(Redis) }
    before { allow(redis).to receive(:multi).and_yield.and_return([results]) }
    before { allow(redis).to receive(:sinter).and_return(results) }

    context "for a simple constraint" do
      let(:constraints) { [con_bar] }

      it "makes a single sinter call and returns the results" do
        expect(query.execute(redis)).to eq(results)

        expect(redis).to have_received(:multi)
        expect(con_bar).not_to have_received(:store_union)
        expect(redis).to have_received(:sinter).with(["key_bar"])
      end
    end

    context "for a complex constraint" do
      let(:constraints) { [con_foo] }

      it "unions and then intersects the result" do
        expect(query.execute(redis)).to eq(results)

        expect(redis).to have_received(:multi)
        expect(con_foo).to have_received(:store_union)
        expect(redis).to have_received(:sinter).with(["key_foo"])
      end
    end

    context "for a varied set of constraints" do
      let(:constraints) { [con_foo, con_bar] }

      it "makes the appropropriate union calls before intersecting" do
        expect(query.execute(redis)).to eq(results)

        expect(redis).to have_received(:multi)
        expect(con_foo).to have_received(:store_union)
        expect(con_bar).not_to have_received(:store_union)
        expect(redis).to have_received(:sinter).with(["key_foo", "key_bar"])
      end
    end
  end
end
