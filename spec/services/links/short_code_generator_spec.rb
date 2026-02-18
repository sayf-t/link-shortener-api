require "rails_helper"

RSpec.describe Links::ShortCodeGenerator do
  describe ".call" do
    it "generates a 7-character code by default" do
      code = described_class.call
      expect(code.length).to eq 7
    end

    it "respects a custom length" do
      expect(described_class.call(length: 10).length).to eq 10
    end

    it "only produces alphanumeric characters" do
      code = described_class.call
      expect(code).to match(/\A[0-9a-zA-Z]+\z/)
    end

    it "generates unique codes across 1000 calls" do
      codes = Array.new(1000) { described_class.call }
      expect(codes.uniq.size).to eq 1000
    end

    it "rejects lengths beyond the max" do
      expect { described_class.call(length: Link::MAX_CODE_LENGTH + 1) }
        .to raise_error(ArgumentError)
    end

    it "raises when all retries collide" do
      allow(SecureRandom).to receive(:alphanumeric).and_return("taken01")
      create(:link, short_code: "taken01")

      expect { described_class.call }.to raise_error(described_class::GenerationError)
    end
  end
end
