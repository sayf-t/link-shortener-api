require 'rails_helper'

RSpec.describe Link, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      expect(Link.new(short_code: 'abc1234', target_url: 'https://test.com')).to be_valid
    end

    it 'requires a target_url' do
      link = Link.new(short_code: 'abc1234', target_url: nil)
      expect(link.valid?).to be false
      expect(link.errors[:target_url]).to include "can't be blank"
    end

    it 'requires a short_code' do
      link = Link.new(short_code: nil, target_url: 'https://test.com')
      expect(link.valid?).to be false
      expect(link.errors[:short_code]).to include "can't be blank"
    end

    it 'requires unique short_codes' do
      Link.create!(short_code: 'abcd123', target_url: 'https://test.com')
      link_2 = Link.new(short_code: 'abcd123', target_url: 'https://test.com')
      expect(link_2.valid?).to be false
      expect(link_2.errors[:short_code]).to include "has already been taken"
    end

    it 'requires max length of 15 on short_code' do
      link = Link.new(short_code: 'a' * 16, target_url: 'https://test.com')
      expect(link).not_to be_valid
    end

    it 'only allows alphanumeric short_codes' do
      link = Link.new(short_code: 'abc-123', target_url: 'https://test.com')
      expect(link).not_to be_valid
      expect(link.errors[:short_code]).to include 'only allows letters and numbers'
    end

    it 'treats short_code uniqueness as case-sensitive' do
      Link.create!(short_code: 'AbCd123', target_url: 'https://test.com')
      link_2 = Link.new(short_code: 'abcd123', target_url: 'https://test2.com')
      expect(link_2).to be_valid
    end

    it 'removes whitespace from target_url' do
      link = Link.new(short_code: 'abc1234', target_url: '  https://test.com  ')
      link.valid?
      expect(link.target_url).to eq 'https://test.com'
    end

    it 'rejects URLs that are not http or https' do
      expect(Link.new(short_code: 'abc1234', target_url: 'not-a-url')).not_to be_valid
      expect(Link.new(short_code: 'abc1234', target_url: 'ftp://test.com')).not_to be_valid
      expect(Link.new(short_code: 'abc1234', target_url: 'https://test.com')).to be_valid
    end
  end
end
