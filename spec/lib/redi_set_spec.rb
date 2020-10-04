require "spec_helper"

RSpec.describe "RediSet" do
  it "exists" do
    expect(RediSet).to be_a(Module)
  end
end
