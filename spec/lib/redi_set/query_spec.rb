require "spec_helper"
require "redis"

RSpec.describe RediSet::Query do
  let(:query_data) { Hash[foo: [:a, :b], bar: [:x]] }
  subject(:query) { RediSet::Query.new(query_data) }

  describe "#constraints" do
    subject(:constraints) { query.constraints }
    it "produces the expected constraints" do
      expect(constraints.map(&:attribute)).to contain_exactly(:foo, :bar)
      expect(constraints.map(&:values)).to contain_exactly([:a, :b], [:x])
    end
  end

  describe "#execute" do
    let(:redis) { instance_double(Redis) }

    context "for a simple constraint" do
      let(:query_data) { Hash[foo: [:a]] }
      let(:results) { ["x", "y", "z"] }

      it "makes a single sinter call and returns the results" do
        expect(redis).to receive(:sinter).with(["rs.attr:foo:a"]).and_return(results)
        expect(redis).to receive(:multi).and_yield.and_return([results])
        expect(redis).not_to receive(:sunionstore)
        expect(redis).not_to receive(:expire)

        expect(query.execute(redis)).to eq(results)
      end
    end

    context "for a set of simple constraints" do
      let(:query_data) { Hash[foo: [:a], bar: [:b], baz: [:c]] }
      let(:results) { ["x", "y", "z"] }

      it "makes a single sinter call and returns the results" do
        expect(redis).to receive(:sinter).
          with(["rs.attr:foo:a", "rs.attr:bar:b", "rs.attr:baz:c"]).
          and_return(results)
        expect(redis).to receive(:multi).and_yield.and_return([results])
        expect(redis).not_to receive(:sunionstore)
        expect(redis).not_to receive(:expire)

        expect(query.execute(redis)).to eq(results)
      end
    end

    context "for a complex set of constraints" do
      let(:query_data) { Hash[foo: [:a], bar: [:b, :c]] }
      let(:fooq) { query.constraints.first }
      let(:barq) { query.constraints.last }
      let(:results) { ["x", "y", "z"] }

      it "makes the appropropriate union calls before intersecting" do
        expect(redis).to receive(:sunionstore).with(barq.union_key, *barq.set_keys)
        expect(redis).to receive(:expire).with(barq.union_key, 60)

        expect(redis).to receive(:sinter).
          with([fooq.set_keys.first, barq.union_key]).
          and_return(results)
        expect(redis).to receive(:multi).and_yield.and_return([results])

        expect(query.execute(redis)).to eq(results)
      end
    end
  end
end
