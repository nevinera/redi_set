require "spec_helper"

RSpec.describe RediSet::Constraint do
  let(:attribute) { "foo" }
  let(:values) { ["a", "b", "c"] }
  let(:uuid) { SecureRandom.uuid }
  before { allow(SecureRandom).to receive(:uuid).and_return(uuid) }
  before { allow(RediSet).to receive(:prefix).and_return("pre") }

  subject(:constraint) do
    RediSet::Constraint.new(attribute: attribute, values: values)
  end

  describe "#requires_union?" do
    subject(:requires_union?) { constraint.requires_union? }

    context "with no values" do
      let(:values) { Array.new }
      it { is_expected.to be false }
    end

    context "with one value" do
      let(:values) { [:a] }
      it { is_expected.to be false }
    end

    context "with several values" do
      let(:values) { [:a, :b, :c] }
      it { is_expected.to be true }
    end
  end

  describe "#intersection_key" do
    subject(:intersection_key) { constraint.intersection_key }

    context "when there are no values" do
      let(:values) { Array.new }
      it { is_expected.to eq(nil) }
    end

    context "when there is one value" do
      let(:values) { [:a] }
      it { is_expected.to eq("pre.attr:foo:a") }
    end

    context "when there are several values" do
      let(:values) { [:a, :b, :c] }
      it { is_expected.to eq("pre.union:#{uuid}") }
    end
  end

  describe "#store_union" do
    let(:redis) { instance_double(Redis, sunionstore: :OK, expire: :OK) }

    it "stores the union properly" do
      constraint.store_union(redis)
      expect(redis).
        to have_received(:sunionstore).
        with("pre.union:#{uuid}", "pre.attr:foo:a", "pre.attr:foo:b", "pre.attr:foo:c")
    end

    it "sets an expiration for the keys" do
      constraint.store_union(redis)
      expect(redis).to have_received(:expire).with("pre.union:#{uuid}", 60)
    end
  end
end
