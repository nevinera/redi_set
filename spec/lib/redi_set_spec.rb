require "spec_helper"

RSpec.describe "RediSet" do
  describe "configuration" do
    before { @prefix = RediSet.prefix }
    after { RediSet.configuration.prefix = @prefix }

    it "supports accessor-based configuration" do
      expect(RediSet.prefix).to eq(@prefix)
      expect(RediSet.configuration.prefix).to eq(@prefix)

      RediSet.configuration.prefix = "something-else"

      expect(RediSet.prefix).to eq("something-else")
      expect(RediSet.configuration.prefix).to eq("something-else")
    end

    it "supports block-based configuration" do
      expect(RediSet.prefix).to eq(@prefix)
      expect(RediSet.configuration.prefix).to eq(@prefix)

      RediSet.configure do |config|
        config.prefix = "something-else"
      end

      expect(RediSet.prefix).to eq("something-else")
      expect(RediSet.configuration.prefix).to eq("something-else")
    end
  end
end
