require "spec_helper"

RSpec.describe RediSet::Constraint do
  let(:attribute) { "foo" }
  let(:values) { ["a", "b", "c"] }
  subject(:constraint) { RediSet::Constraint.new(attribute: attribute, values: values) }

  describe "#set_keys" do
    subject(:set_keys) { constraint.set_keys }

    context "with no values" do
      let(:values) { Array.new }
      it { is_expected.to be_empty }
    end

    context "with string values" do
      let(:values) { ["a", "b"] }
      it { is_expected.to contain_exactly("rs.attr:foo:a", "rs.attr:foo:b") }
    end

    context "with various likely types of values" do
      let(:values) { ["a", :b, 3] }
      it { is_expected.to contain_exactly("rs.attr:foo:a", "rs.attr:foo:b", "rs.attr:foo:3") }
    end
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

  describe "#union_key" do
    subject(:union_key) { constraint.union_key }
    let(:fake_uuid) { SecureRandom.uuid }
    before { allow(SecureRandom).to receive(:uuid).and_return(fake_uuid) }

    it { is_expected.to eq("rs.union:#{fake_uuid}") }

    it "is memoized" do
      expect(SecureRandom).to receive(:uuid).once
      expect(constraint.union_key).to eq(constraint.union_key)
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
      it { is_expected.to eq(constraint.set_keys.first) }
    end

    context "when there are several values" do
      let(:values) { [:a, :b, :c] }
      it { is_expected.to eq(constraint.union_key) }
    end
  end
end
