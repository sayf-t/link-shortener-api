module Api
  module V1
    class LinksController < ApplicationController
      def create
        link = Link.create!(
          short_code: Links::ShortCodeGenerator.call,
          target_url: link_params[:target_url]
        )
        enqueue_link_title_fetch(link)

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
          title: link.title,
          total_clicks: events.count,
          clicks_by_country: normalize_country_buckets(events.group(:geo_country).count),
          clicks_by_date: events.group("DATE(timestamp)").count,
          visits: events.order(timestamp: :desc).map { |event|
            {
              timestamp: event.timestamp.iso8601,
              geo_country: event.geo_country.presence || "UNKNOWN"
            }
          }
        }
      end

      def normalize_country_buckets(raw)
        raw.each_with_object({}) do |(country, count), out|
          key = country.presence || "UNKNOWN"
          out[key] = out.fetch(key, 0) + count
        end
      end

      private

      def enqueue_link_title_fetch(link)
        FetchLinkTitleJob.perform_later(link.id)
      rescue StandardError => e
        Rails.logger.error(
          "Failed to enqueue FetchLinkTitleJob for link_id=#{link.id}: #{e.class}: #{e.message}"
        )
      end

      def link_params
        params.expect(link: [ :target_url ])
      end
    end
  end
end
