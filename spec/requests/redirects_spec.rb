require "rails_helper"

RSpec.describe "Redirects", type: :request do
  include ActiveJob::TestHelper

  let!(:link) { create(:link, short_code: "redir12", target_url: "https://example.com") }

  describe "GET /:short_code" do
    it "redirects and enqueues click recording" do
      get "/redir12"

      expect(response).to redirect_to("https://example.com")
      expect(RecordClickJob).to have_been_enqueued.with(
        link_id: link.id,
        ip: anything,
        user_agent: anything,
        timestamp: anything
      )
    end

    it "returns 404 for unknown codes" do
      get "/unknown1"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Short link not found")
    end
  end

  describe "HEAD /:short_code" do
    it "redirects without enqueuing a click" do
      head "/redir12"

      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to eq("https://example.com")
      expect(RecordClickJob).not_to have_been_enqueued
    end
  end
end
