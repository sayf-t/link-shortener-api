require "rails_helper"

RSpec.describe Clicks::RecorderService do
  let(:link) { create(:link) }

  describe ".call" do
    it "creates a click event with geocoded country and hashed IP" do
      geo_result = instance_double(Geocoder::Result::Base, country_code: "SG")
      allow(Geocoder).to receive(:search).with("1.1.1.1").and_return([ geo_result ])

      event = described_class.call(link: link, ip: "1.1.1.1", user_agent: "RSpec")

      expect(event).to be_persisted
      expect(event.geo_country).to eq("SG")
      expect(event.user_agent).to eq("RSpec")
      expect(event.ip_hash).to eq(Digest::SHA256.hexdigest("1.1.1.1"))
    end

    it "skips geocoding when geo_country is provided" do
      allow(Geocoder).to receive(:search)

      event = described_class.call(link: link, ip: "1.1.1.1", user_agent: "RSpec", geo_country: "MY")

      expect(event.geo_country).to eq("MY")
      expect(Geocoder).not_to have_received(:search)
    end

    it "handles geocoding failures gracefully" do
      allow(Geocoder).to receive(:search).and_raise(SocketError)

      event = described_class.call(link: link, ip: "1.1.1.1", user_agent: "RSpec")
      expect(event.geo_country).to be_nil
    end

    it "skips geocoding for loopback IPs" do
      allow(Geocoder).to receive(:search)

      event = described_class.call(link: link, ip: "127.0.0.1", user_agent: "RSpec")

      expect(event.geo_country).to be_nil
      expect(Geocoder).not_to have_received(:search)
    end

    it "skips geocoding for private IPs" do
      allow(Geocoder).to receive(:search)

      event = described_class.call(link: link, ip: "192.168.1.1", user_agent: "RSpec")

      expect(event.geo_country).to be_nil
      expect(Geocoder).not_to have_received(:search)
    end

    it "skips geocoding for IPv6 loopback" do
      allow(Geocoder).to receive(:search)

      event = described_class.call(link: link, ip: "::1", user_agent: "RSpec")

      expect(event.geo_country).to be_nil
      expect(Geocoder).not_to have_received(:search)
    end
  end
end
