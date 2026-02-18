module Links
  class TitleFetcher
    CONNECT_TIMEOUT = 3
    READ_TIMEOUT = 5
    TITLE_PATTERN = %r{<title[^>]*>(.*?)</title>}im

    def self.call(url)
      new(url).call
    end

    def initialize(url)
      @url = url.to_s.strip
    end

    def call
      return nil if @url.blank?

      response = Faraday.get(@url) do |req|
        req.options.open_timeout = CONNECT_TIMEOUT
        req.options.timeout = READ_TIMEOUT
      end

      return nil unless response.success?

      extract_title(response.body)
    rescue Faraday::Error, URI::InvalidURIError, ArgumentError
      nil
    end

    private

    def extract_title(html)
      return nil if html.blank?

      match = html.match(TITLE_PATTERN)
      match && match[1].strip.presence
    end
  end
end
