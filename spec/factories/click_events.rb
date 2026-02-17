FactoryBot.define do
  factory :click_event do
    link
    timestamp { Time.current }
    geo_country { nil }
    ip_hash { nil }
    user_agent { "Mozilla/5.0" }
  end
end
