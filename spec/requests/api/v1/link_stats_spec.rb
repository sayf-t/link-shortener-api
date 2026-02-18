require 'rails_helper'

RSpec.describe 'Api::V1::LinkStats', type: :request do
  describe 'GET /api/v1/links/:short_code/stats' do
    it 'returns analytics for an existing link' do
      link = Link.create!(short_code: 'stats777', target_url: 'https://example.com')
      link.click_events.create!(timestamp: Time.zone.parse('2026-02-17 10:00:00'), geo_country: 'SG')
      link.click_events.create!(timestamp: Time.zone.parse('2026-02-18 10:00:00'), geo_country: 'US')

      get "/api/v1/links/#{link.short_code}/stats"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['short_code']).to eq('stats777')
      expect(body['total_clicks']).to eq(2)
      expect(body['clicks_by_country']).to eq({ 'SG' => 1, 'US' => 1 })
    end

    it 'returns 404 for unknown link short_code' do
      get '/api/v1/links/missing123/stats'

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body).to eq({ 'error' => 'Link not found' })
    end
  end
end
