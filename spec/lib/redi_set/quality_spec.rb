require "spec_helper"

RSpec.describe RediSet::Quality do
  let(:attribute) { RediSet::Attribute.new(name: "foo") }
  let(:name) { "bar" }
  let(:quality) { described_class.new(attribute: attribute, name: name) }

  describe "#key" do
    subject(:key) { quality.key }
    before { allow(RediSet).to receive(:prefix).and_return("prefixinator") }
    it { is_expected.to eq("prefixinator.attr:foo:bar") }
  end
end
