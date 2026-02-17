require 'rails_helper'

RSpec.describe ClickEvent, type: :model do
  it 'must belong to a link' do
    event = ClickEvent.new(timestamp: Time.current, link: nil)
    expect(event).not_to be_valid
  end

  it 'is valid with a link and clicked_at' do
    link = Link.create!(short_code: 'abc1234', target_url: 'https://test.com')
    event = ClickEvent.new(link: link, timestamp: Time.current)
    expect(event).to be_valid
  end

  describe 'link association' do
    it 'a link can have many click_events' do
      link = Link.create!(short_code: 'xyz7890', target_url: 'https://test.com')
      link.click_events.create!(timestamp: 1.hour.ago)
      link.click_events.create!(timestamp: Time.current)
      expect(link.click_events.count).to eq 2
    end

    it 'click_events are removed when the link is destroyed' do
      link = Link.create!(short_code: 'gone123', target_url: 'https://test.com')
      link.click_events.create!(timestamp: Time.current)
      link.destroy
      expect(ClickEvent.count).to eq 0
    end
  end
end
