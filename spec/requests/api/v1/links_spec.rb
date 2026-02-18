require 'rails_helper'

RSpec.describe 'Api::V1::Links', type: :request do
  describe 'POST /api/v1/links' do
    it 'creates a short link and returns JSON' do
      allow(Links::TitleFetcher).to receive(:call).and_return('Example Site')
      allow(Links::ShortCodeGenerator).to receive(:call).and_return('abc1234')

      post '/api/v1/links', params: { link: { target_url: 'https://example.com' } }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['short_code']).to eq('abc1234')
      expect(body['short_url']).to end_with('/abc1234')
      expect(body['target_url']).to eq('https://example.com')
      expect(body['title']).to eq('Example Site')
    end

    it 'returns 422 for invalid URL' do
      allow(Links::TitleFetcher).to receive(:call).and_return(nil)
      allow(Links::ShortCodeGenerator).to receive(:call).and_return('abc1234')

      post '/api/v1/links', params: { link: { target_url: 'not-a-url' } }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['errors'].join).to include('must be a valid HTTP or HTTPS URL')
    end
  end
end
