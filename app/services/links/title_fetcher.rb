module Links
  class TitleFetcher
    CONNECT_TIMEOUT = 3
    READ_TIMEOUT = 5
    USER_AGENT = "Mozilla/5.0 (compatible; LinkShortener/1.0)"
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

      response = Faraday.get(@url) do |req|
        req.headers["User-Agent"] = USER_AGENT
        req.headers["Accept"] = "text/html"
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

    def html_content?(response)
      content_type = response.headers["content-type"].to_s
      content_type.include?("text/html") || content_type.empty?
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
