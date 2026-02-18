require "rails_helper"

RSpec.describe "Api::V1::Links", type: :request do
  include ActiveJob::TestHelper

  describe "POST /api/v1/links" do
    before do
      allow(Links::ShortCodeGenerator).to receive(:call).and_return("abc1234")
    end

    it "creates a short link and enqueues title fetch" do
      post "/api/v1/links", params: { link: { target_url: "https://example.com" } }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["short_code"]).to eq("abc1234")
      expect(body["short_url"]).to end_with("/abc1234")
      expect(body["target_url"]).to eq("https://example.com")
      expect(body["title"]).to be_nil

      expect(FetchLinkTitleJob).to have_been_enqueued.with(Link.last.id)
    end

    it "rejects invalid URLs with 422" do
      post "/api/v1/links", params: { link: { target_url: "not-a-url" } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = response.parsed_body
      expect(body["errors"].join).to include("must be a valid HTTP or HTTPS URL")
    end

    it "still creates a short link when enqueue fails" do
      allow(FetchLinkTitleJob).to receive(:perform_later).and_raise(ActiveJob::EnqueueError, "boom")

      post "/api/v1/links", params: { link: { target_url: "https://example.com" } }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["short_code"]).to eq("abc1234")
      expect(body["target_url"]).to eq("https://example.com")
    end
  end
end
