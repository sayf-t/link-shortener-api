require "rails_helper"

RSpec.describe Link, type: :model do
  describe "validations" do
    it "is valid with all required attributes" do
      expect(build(:link)).to be_valid
    end

    it "requires a target_url" do
      link = build(:link, target_url: nil)
      expect(link).not_to be_valid
      expect(link.errors[:target_url]).to include "can't be blank"
    end

    it "requires a short_code" do
      link = build(:link, short_code: nil)
      expect(link).not_to be_valid
      expect(link.errors[:short_code]).to include "can't be blank"
    end

    it "requires unique short_codes" do
      existing = create(:link, short_code: "abcd123")
      dupe = build(:link, short_code: existing.short_code)
      expect(dupe).not_to be_valid
      expect(dupe.errors[:short_code]).to include "has already been taken"
    end

    it "caps short_code at 15 characters" do
      link = build(:link, short_code: "a" * 16)
      expect(link).not_to be_valid
    end

    it "only allows alphanumeric short_codes" do
      link = build(:link, short_code: "abc-123")
      expect(link).not_to be_valid
      expect(link.errors[:short_code]).to include "only allows letters and numbers"
    end

    it "treats short_code uniqueness as case-sensitive" do
      create(:link, short_code: "AbCd123")
      link = build(:link, short_code: "abcd123")
      expect(link).to be_valid
    end

    it "strips whitespace from target_url" do
      link = build(:link, target_url: "  https://test.com  ")
      link.valid?
      expect(link.target_url).to eq "https://test.com"
    end

    it "rejects non-HTTP URLs" do
      expect(build(:link, target_url: "not-a-url")).not_to be_valid
      expect(build(:link, target_url: "ftp://test.com")).not_to be_valid
      expect(build(:link, target_url: "https://test.com")).to be_valid
    end
  end
end
