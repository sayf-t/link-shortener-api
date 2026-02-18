require 'rails_helper'

RSpec.describe Links::ShortCodeGenerator do
  describe '.call' do
    it 'generates a string of the requested length' do
      expect(described_class.call(length: 7).length).to eq 7
    end

    it 'defaults to 7 characters' do
      expect(described_class.call.length).to eq 7
    end

    it 'only contains base62 characters (0-9, a-z, A-Z)' do
      code = described_class.call
      expect(code).to match(/\A[0-9a-zA-Z]+\z/)
    end

    it 'produces unique values across many calls' do
      codes = Set.new(1000.times.map { described_class.call })
      expect(codes.size).to eq 1000
    end

    it 'raises ArgumentError when length is greater than max allowed' do
      expect { described_class.call(length: Link::MAX_CODE_LENGTH + 1) }
        .to raise_error(ArgumentError)
    end

    it 'raises GenerationError when all retries collide' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('taken01')
      Link.create!(short_code: 'taken01', target_url: 'https://example.com')

      expect { described_class.call }.to raise_error(described_class::GenerationError)
    end
  end
end
