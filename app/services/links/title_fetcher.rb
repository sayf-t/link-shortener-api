class Links::TitleFetcher
  CONNECTION_TIMEOUT_SECONDS = 3
  REQUEST_TIMEOUT_SECONDS = 5
  TITLE_REGEX = %r{<title[^>]*>(.*?)</title>}im

  def self.call(url)
    normalized_url = url.to_s.strip
    return nil if normalized_url.blank?

    response = Faraday.get(normalized_url) do |request|
      request.options.open_timeout = CONNECTION_TIMEOUT_SECONDS
      request.options.timeout = REQUEST_TIMEOUT_SECONDS
    end

    return nil unless response.success?

    extract_title(response.body)
  rescue Faraday::Error, URI::InvalidURIError, ArgumentError
    nil
  end

  def self.extract_title(body)
    return nil if body.blank?

    match = body.match(TITLE_REGEX)
    return nil unless match

    title = match[1].to_s.strip
    title.present? ? title : nil
  end

  private_class_method :extract_title
end
