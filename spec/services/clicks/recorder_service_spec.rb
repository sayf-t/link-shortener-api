require 'rails_helper'

RSpec.describe Clicks::RecorderService do
  describe '.call' do
    let(:link) { Link.create!(short_code: 'abc1234', target_url: 'https://example.com') }

    it 'creates click event with geocoded country and hashed ip' do
      geocoded = instance_double(Geocoder::Result::Base, country_code: 'SG')
      allow(Geocoder).to receive(:search).with('1.1.1.1').and_return([geocoded])

      event = described_class.call(link: link, ip: '1.1.1.1', user_agent: 'RSpec')

      expect(event).to be_persisted
      expect(event.geo_country).to eq('SG')
      expect(event.user_agent).to eq('RSpec')
      expect(event.ip_hash).to eq(Digest::SHA256.hexdigest('1.1.1.1'))
    end

    it 'uses provided geo_country when passed' do
      allow(Geocoder).to receive(:search)

      event = described_class.call(link: link, ip: '1.1.1.1', user_agent: 'RSpec', geo_country: 'MY')

      expect(event.geo_country).to eq('MY')
      expect(Geocoder).not_to have_received(:search)
    end

    it 'falls back to nil country when geocoding fails' do
      allow(Geocoder).to receive(:search).and_raise(StandardError)

      event = described_class.call(link: link, ip: '1.1.1.1', user_agent: 'RSpec')
      expect(event.geo_country).to be_nil
    end
  end
end
