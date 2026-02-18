require "rails_helper"

RSpec.describe RecordClickJob, type: :job do
  include ActiveJob::TestHelper

  let(:link) { create(:link) }

  it "delegates to Clicks::RecorderService" do
    allow(Clicks::RecorderService).to receive(:call)
    timestamp = "2026-02-18T12:00:00Z"

    perform_enqueued_jobs do
      described_class.perform_later(
        link_id: link.id, ip: "1.2.3.4", user_agent: "RSpec", timestamp: timestamp
      )
    end

    expect(Clicks::RecorderService).to have_received(:call).with(
      link: link,
      ip: "1.2.3.4",
      user_agent: "RSpec",
      timestamp: Time.zone.parse(timestamp)
    )
  end

  it "is enqueued on the default queue" do
    assert_enqueued_with(job: described_class, queue: "default") do
      described_class.perform_later(
        link_id: link.id, ip: "1.2.3.4", user_agent: "RSpec", timestamp: Time.current.iso8601
      )
    end
  end
end
