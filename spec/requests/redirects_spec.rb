require "rails_helper"

RSpec.describe "Redirects", type: :request do
  let!(:link) { create(:link, short_code: "redir12", target_url: "https://example.com") }

  describe "GET /:short_code" do
    it "redirects and records the click" do
      allow(Clicks::RecorderService).to receive(:call)

      get "/redir12"

      expect(response).to redirect_to("https://example.com")
      expect(Clicks::RecorderService).to have_received(:call).with(
        link: link,
        ip: anything,
        user_agent: anything
      )
    end

    it "returns 404 for unknown codes" do
      get "/unknown1"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Short link not found")
    end
  end

  describe "HEAD /:short_code" do
    it "redirects without recording a click" do
      allow(Clicks::RecorderService).to receive(:call)

      head "/redir12"

      expect(response).to have_http_status(:found)
      expect(response.headers["Location"]).to eq("https://example.com")
      expect(Clicks::RecorderService).not_to have_received(:call)
    end
  end
end
