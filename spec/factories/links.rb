FactoryBot.define do
  factory :link do
    short_code { SecureRandom.alphanumeric(7) }
    target_url { "https://example.com/#{SecureRandom.hex(4)}" }
    title { nil }
  end
end
