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
end
