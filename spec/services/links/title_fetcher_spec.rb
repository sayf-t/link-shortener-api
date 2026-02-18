require "rails_helper"

RSpec.describe Links::TitleFetcher do
  describe ".call" do
    it "parses the <title> from a valid HTML page" do
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: "<html><head><title>Example</title></head></html>",
                   headers: { "Content-Type" => "text/html" })

      expect(described_class.call("https://example.com")).to eq("Example")
    end

    it "falls back to og:title when <title> is absent" do
      html = '<html><head><meta property="og:title" content="OG Title Here"></head></html>'
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html, headers: { "Content-Type" => "text/html" })

      expect(described_class.call("https://example.com")).to eq("OG Title Here")
    end

    it "prefers <title> over og:title" do
      html = '<html><head><title>Main Title</title><meta property="og:title" content="OG Title"></head></html>'
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html, headers: { "Content-Type" => "text/html" })

      expect(described_class.call("https://example.com")).to eq("Main Title")
    end

    it "returns nil for non-HTML content types" do
      stub_request(:get, "https://example.com/file.pdf")
        .to_return(status: 200, body: "%PDF-1.4", headers: { "Content-Type" => "application/pdf" })

      expect(described_class.call("https://example.com/file.pdf")).to be_nil
    end

    it "sends a browser-like User-Agent header" do
      stub_request(:get, "https://example.com")
        .with(headers: { "User-Agent" => Links::TitleFetcher::USER_AGENT })
        .to_return(status: 200, body: "<title>Works</title>",
                   headers: { "Content-Type" => "text/html" })

      expect(described_class.call("https://example.com")).to eq("Works")
    end

    it "returns nil when there is no title or og:title" do
      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: "<html><body>Nothing here</body></html>",
                   headers: { "Content-Type" => "text/html" })

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
