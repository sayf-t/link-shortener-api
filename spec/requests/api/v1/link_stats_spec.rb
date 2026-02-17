require "rails_helper"

RSpec.describe "Api::V1::LinkStats", type: :request do
  describe "GET /api/v1/links/:short_code/stats" do
    it "returns click analytics for a link" do
      link = create(:link, short_code: "stats77")
      create(:click_event, link: link, timestamp: Time.zone.parse("2026-02-17 10:00"), geo_country: "SG")
      create(:click_event, link: link, timestamp: Time.zone.parse("2026-02-18 10:00"), geo_country: "US")

      get "/api/v1/links/#{link.short_code}/stats"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["short_code"]).to eq("stats77")
      expect(body["total_clicks"]).to eq(2)
      expect(body["clicks_by_country"]).to include("SG" => 1, "US" => 1)
    end

    it "returns 404 for a missing short_code" do
      get "/api/v1/links/nope123/stats"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Link not found")
    end
  end
end
