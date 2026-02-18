require 'rails_helper'

RSpec.describe Links::TitleFetcher do
  describe '.call' do
    it 'returns the title from a valid HTML page' do
      stub_request(:get, 'https://example.com')
        .to_return(status: 200, body: '<html><head><title>Example</title></head></html>')

      expect(described_class.call('https://example.com')).to eq('Example')
    end

    it 'returns nil when page has no title tag' do
      stub_request(:get, 'https://example.com')
        .to_return(status: 200, body: '<html><body>No title here</body></html>')

      expect(described_class.call('https://example.com')).to be_nil
    end

    it 'returns nil on HTTP timeout' do
      stub_request(:get, 'https://example.com').to_timeout

      expect(described_class.call('https://example.com')).to be_nil
    end

    it 'returns nil on HTTP error (e.g. 500)' do
      stub_request(:get, 'https://example.com')
        .to_return(status: 500, body: 'Server Error')

      expect(described_class.call('https://example.com')).to be_nil
    end

    it 'returns nil on connection failure' do
      stub_request(:get, 'https://example.com').to_raise(Faraday::ConnectionFailed.new('connection failed'))

      expect(described_class.call('https://example.com')).to be_nil
    end

    it 'returns nil for non-string url inputs' do
      expect(described_class.call({ target_url: 'https://example.com' })).to be_nil
    end
  end
end
