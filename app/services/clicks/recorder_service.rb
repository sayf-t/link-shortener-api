require 'digest'

module Clicks
  class RecorderService
    def self.call(link:, ip:, user_agent:, timestamp: Time.current, geo_country: nil)
      ClickEvent.create!(
        link: link,
        timestamp: timestamp,
        geo_country: geo_country || geocode_country(ip),
        ip_hash: hash_ip(ip),
        user_agent: user_agent
      )
    end

    def self.hash_ip(ip)
      return nil if ip.blank?

      Digest::SHA256.hexdigest(ip.to_s)
    end

    def self.geocode_country(ip)
      return nil if ip.blank?

      Geocoder.search(ip).first&.country_code
    rescue StandardError
      nil
    end

    private_class_method :hash_ip
    private_class_method :geocode_country
  end
end
