class RecordClickJob < ApplicationJob
  queue_as :default

  def perform(link_id:, ip:, user_agent:, timestamp:)
    link = Link.find(link_id)
    Clicks::RecorderService.call(
      link: link, ip: ip, user_agent: user_agent, timestamp: Time.zone.parse(timestamp)
    )
  end
end
