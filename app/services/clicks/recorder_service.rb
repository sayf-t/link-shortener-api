module Clicks
  class RecorderService
    def self.call(link:, ip:, user_agent:, timestamp: Time.current, geo_country: nil)
      new(link:, ip:, user_agent:, timestamp:, geo_country:).call
    end

    def initialize(link:, ip:, user_agent:, timestamp:, geo_country:)
      @link = link
      @ip = ip
      @user_agent = user_agent
      @timestamp = timestamp
      @geo_country = geo_country
    end

    def call
      ClickEvent.create!(
        link: @link,
        timestamp: @timestamp,
        geo_country: @geo_country || resolve_country,
        ip_hash: hashed_ip,
        user_agent: @user_agent
      )
    end

    private

    def hashed_ip
      return nil if @ip.blank?
      Digest::SHA256.hexdigest(@ip.to_s)
    end

    def resolve_country
      return nil if @ip.blank?
      return nil unless geocodable_ip?

      Geocoder.search(@ip).first&.country_code.then { |code| code.presence }
    rescue StandardError
      nil
    end

    def geocodable_ip?
      addr = IPAddr.new(@ip)
      !(addr.loopback? || addr.private? || addr.link_local?)
    rescue IPAddr::InvalidAddressError
      false
    end
  end
end
