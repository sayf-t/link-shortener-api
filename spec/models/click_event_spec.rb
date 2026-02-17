require "rails_helper"

RSpec.describe ClickEvent, type: :model do
  it "must belong to a link" do
    event = build(:click_event, link: nil)
    expect(event).not_to be_valid
  end

  it "is valid with a link and timestamp" do
    expect(build(:click_event)).to be_valid
  end

  describe "association" do
    let(:link) { create(:link) }

    it "supports many click_events per link" do
      create(:click_event, link: link, timestamp: 1.hour.ago)
      create(:click_event, link: link, timestamp: Time.current)
      expect(link.click_events.count).to eq 2
    end

    it "destroys events when the link is deleted" do
      create(:click_event, link: link)
      expect { link.destroy }.to change(ClickEvent, :count).by(-1)
    end
  end
end
