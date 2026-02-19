require "faraday/follow_redirects"

module Links
  class TitleFetcher
    CONNECT_TIMEOUT = 5
    READ_TIMEOUT = 10
    MAX_REDIRECTS = 5
    USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    TITLE_PATTERN = %r{<title[^>]*>(.*?)</title>}im
    OG_TITLE_PATTERN = %r{<meta[^>]+property=["']og:title["'][^>]+content=["']([^"']+)["']}im

    def self.call(url)
      new(url).call
    end

    def initialize(url)
      @url = url.to_s.strip
    end

    def call
      return nil if @url.blank?

      response = connection.get(@url) do |req|
        req.headers["User-Agent"] = USER_AGENT
        req.headers["Accept"] = "text/html,application/xhtml+xml"
        req.options.open_timeout = CONNECT_TIMEOUT
        req.options.timeout = READ_TIMEOUT
      end

      return nil unless response.success?
      return nil unless html_content?(response)

      extract_title(response.body)
    rescue Faraday::Error, URI::InvalidURIError, ArgumentError
      nil
    end

    private

    def connection
      @connection ||= Faraday.new do |f|
        f.response :follow_redirects, limit: MAX_REDIRECTS
        f.adapter Faraday.default_adapter
      end
    end

    def html_content?(response)
      content_type = response.headers["content-type"].to_s.downcase
      content_type.include?("text/html") ||
        content_type.include?("application/xhtml+xml") ||
        content_type.empty?
    end

    def extract_title(html)
      return nil if html.blank?

      title_match = html.match(TITLE_PATTERN)
      title = title_match && title_match[1].strip.presence

      return title if title

      og_match = html.match(OG_TITLE_PATTERN)
      og_match && og_match[1].strip.presence
    end
  end
end
