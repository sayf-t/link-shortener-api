require "rails_helper"

RSpec.describe Links::TitleFetcher do
  describe ".call" do
    it "parses the <title> from a valid HTML page" do
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: "<html><head><title>Example</title></head></html>")

      expect(described_class.call("https://example.com")).to eq("Example")
    end

    it "returns nil when there is no title tag" do
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: "<html><body>Nothing here</body></html>")

      expect(described_class.call("https://example.com")).to be_nil
    end

    it "returns nil on timeout" do
      stub_request(:get, "https://example.com").to_timeout

      expect(described_class.call("https://example.com")).to be_nil
    end

    it "returns nil on server error" do
      stub_request(:get, "https://example.com")
        .to_return(status: 500, body: "Server Error")

      expect(described_class.call("https://example.com")).to be_nil
    end

    it "returns nil on connection failure" do
      stub_request(:get, "https://example.com")
        .to_raise(Faraday::ConnectionFailed.new("nope"))

      expect(described_class.call("https://example.com")).to be_nil
    end

    it "handles non-string input without crashing" do
      expect(described_class.call({ foo: "bar" })).to be_nil
    end
  end
end
