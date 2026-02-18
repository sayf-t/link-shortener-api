class FetchLinkTitleJob < ApplicationJob
  queue_as :default
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 3

  def perform(link_id)
    link = Link.find(link_id)
    title = Links::TitleFetcher.call(link.target_url)
    link.update!(title: title) if title.present?
  end
end
