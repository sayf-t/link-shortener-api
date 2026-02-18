require "rails_helper"

RSpec.describe "Api::V1::LinkStats", type: :request do
  describe "GET /api/v1/links/:short_code/stats" do
    it "returns click analytics including title" do
      link = create(:link, short_code: "stats77", title: "My Page")
      create(:click_event, link: link, timestamp: Time.zone.parse("2026-02-17 10:00"), geo_country: "SG")
      create(:click_event, link: link, timestamp: Time.zone.parse("2026-02-18 10:00"), geo_country: "US")

      get "/api/v1/links/#{link.short_code}/stats"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["short_code"]).to eq("stats77")
      expect(body["title"]).to eq("My Page")
      expect(body["total_clicks"]).to eq(2)
      expect(body["clicks_by_country"]).to include("SG" => 1, "US" => 1)
      expect(body["visits"]).to be_an(Array)
      expect(body["visits"].length).to eq(2)
      expect(body["visits"].first).to include("timestamp", "geo_country")
      expect(body["visits"].first["geo_country"]).to eq("US")
      expect(body["visits"].last["geo_country"]).to eq("SG")
    end

    it "maps nil geo_country to UNKNOWN" do
      link = create(:link, short_code: "geo0001")
      create(:click_event, link: link, geo_country: nil)
      create(:click_event, link: link, geo_country: "")
      create(:click_event, link: link, geo_country: "SG")

      get "/api/v1/links/#{link.short_code}/stats"

      body = response.parsed_body
      expect(body["clicks_by_country"]).to eq("UNKNOWN" => 2, "SG" => 1)
      expect(body["clicks_by_country"].keys).not_to include("", nil)
      expect(body["visits"].map { |v| v["geo_country"] }).to match_array([ "UNKNOWN", "UNKNOWN", "SG" ])
    end

    it "returns 404 for a missing short_code" do
      get "/api/v1/links/nope123/stats"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "Link not found")
    end
  end
end
