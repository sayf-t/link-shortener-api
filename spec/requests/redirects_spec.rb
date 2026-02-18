require 'rails_helper'

RSpec.describe 'Redirects', type: :request do
  describe 'GET /:short_code' do
    it 'redirects to target_url and records click event' do
      link = Link.create!(short_code: 'redir123', target_url: 'https://example.com')
      allow(Clicks::RecorderService).to receive(:call)

      get '/redir123'

      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to eq('https://example.com')
      expect(Clicks::RecorderService).to have_received(:call).with(
        link: link,
        ip: anything,
        user_agent: anything
      )
    end

    it 'returns 404 for unknown short_code' do
      get '/unknown123'

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Short link not found')
    end
  end

  describe 'HEAD /:short_code' do
    it 'returns redirect headers without recording click event' do
      Link.create!(short_code: 'head123', target_url: 'https://example.com')
      allow(Clicks::RecorderService).to receive(:call)

      head '/head123'

      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to eq('https://example.com')
      expect(Clicks::RecorderService).not_to have_received(:call)
    end
  end
end
