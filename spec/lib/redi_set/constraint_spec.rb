require "spec_helper"

RSpec.describe RediSet::Constraint do
  subject(:constraint) { RediSet::Constraint.new(qualities: qualities) }
  let(:attribute) { RediSet::Attribute.new(name: "foo") }
  let(:q1) { RediSet::Quality.new(attribute: attribute, name: "a") }
  let(:q2) { RediSet::Quality.new(attribute: attribute, name: "b") }
  let(:q3) { RediSet::Quality.new(attribute: attribute, name: "c") }
  let(:qualities) { [q1, q2] }

  let(:uuid) { SecureRandom.uuid }
  before do
    allow(SecureRandom).to receive(:uuid).and_return(uuid)
    allow(RediSet).to receive(:prefix).and_return("pre")
  end

  describe "#initialize" do
    subject(:init) { -> { RediSet::Constraint.new(qualities: qualities) } }

    context "with zero qualities" do
      let(:qualities) { Array.new }
      it { is_expected.to raise_error(ArgumentError, /at least one quality/) }
    end

    context "with one quality" do
      let(:qualities) { [RediSet::Quality.new(attribute: attribute, name: "bar")] }
      it { is_expected.not_to raise_error }
    end

    context "with multiple qualities" do
      context "with matching attribute" do
        let(:qualities) { [q1, q2] }
        it { is_expected.not_to raise_error }
      end

      context "with varying attribute" do
        let(:other_attr) { RediSet::Attribute.new(name: "bar") }
        let(:q3) { RediSet::Quality.new(attribute: other_attr, name: "c") }
        let(:qualities) { [q1, q2, q3] }
        it { is_expected.to raise_error(ArgumentError, /matching attributes/) }
      end
    end
  end

  describe "#requires_union?" do
    subject(:requires_union?) { constraint.requires_union? }

    context "with one value" do
      let(:qualities) { [q1] }
      it { is_expected.to be false }
    end

    context "with several values" do
      let(:qualities) { [q1, q2] }
      it { is_expected.to be true }
    end
  end

  describe "#intersection_key" do
    subject(:intersection_key) { constraint.intersection_key }

    context "when there is one quality" do
      let(:qualities) { [q1] }
      it { is_expected.to eq(q1.key) }
    end

    context "when there are several qualities" do
      let(:qualities) { [q1, q2] }
      it { is_expected.to eq("pre.union:#{uuid}") }
    end
  end

  describe "#store_union" do
    let(:redis) { instance_double(Redis, sunionstore: :OK, expire: :OK) }
    let(:qualities) { [q1, q2, q3] }

    it "stores the union properly" do
      constraint.store_union(redis)
      expect(redis).
        to have_received(:sunionstore).
        with("pre.union:#{uuid}", [q1.key, q2.key, q3.key])
    end

    it "sets an expiration for the keys" do
      constraint.store_union(redis)
      expect(redis).to have_received(:expire).with("pre.union:#{uuid}", 60)
    end
  end
end
