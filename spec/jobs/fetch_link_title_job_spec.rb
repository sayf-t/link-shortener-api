require "rails_helper"

RSpec.describe FetchLinkTitleJob, type: :job do
  include ActiveJob::TestHelper

  let(:link) { create(:link, target_url: "https://example.com", title: nil) }

  it "updates the link title when TitleFetcher returns a value" do
    allow(Links::TitleFetcher).to receive(:call)
      .with("https://example.com").and_return("Example Site")

    perform_enqueued_jobs { described_class.perform_later(link.id) }

    expect(link.reload.title).to eq("Example Site")
  end

  it "leaves the title nil when TitleFetcher returns nil" do
    allow(Links::TitleFetcher).to receive(:call).and_return(nil)

    perform_enqueued_jobs { described_class.perform_later(link.id) }

    expect(link.reload.title).to be_nil
  end

  it "retries on Faraday errors" do
    allow(Links::TitleFetcher).to receive(:call)
      .and_raise(Faraday::ConnectionFailed.new("nope"))

    perform_enqueued_jobs(only: []) { described_class.perform_later(link.id) }

    assert_enqueued_jobs 1, only: described_class
  end

  it "is enqueued on the default queue" do
    assert_enqueued_with(job: described_class, queue: "default") do
      described_class.perform_later(link.id)
    end
  end
end
