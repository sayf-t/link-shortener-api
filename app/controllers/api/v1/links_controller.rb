module Api
  module V1
    class LinksController < ApplicationController
      def create
        link = Link.create!(
          short_code: Links::ShortCodeGenerator.call,
          target_url: link_params[:target_url],
          title: Links::TitleFetcher.call(link_params[:target_url])
        )

        render json: {
          short_code: link.short_code,
          short_url: "#{request.base_url}/#{link.short_code}",
          target_url: link.target_url,
          title: link.title
        }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def stats
        link = Link.find_by!(short_code: params[:short_code])
        events = link.click_events

        render json: {
          short_code: link.short_code,
          total_clicks: events.count,
          clicks_by_country: events.group(:geo_country).count,
          clicks_by_date: events.group("DATE(timestamp)").count
        }
      end

      private

      def link_params
        params.expect(link: [ :target_url ])
      end
    end
  end
end
