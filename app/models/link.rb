class Link < ApplicationRecord
  MAX_CODE_LENGTH = 15
  MIN_CUSTOM_LENGTH = 8

  has_many :click_events, dependent: :destroy

  normalizes :target_url, with: ->(url) { url.to_s.strip }

  validates :short_code, presence: true,
                         uniqueness: true,
                         length: { maximum: MAX_CODE_LENGTH },
                         format: { with: /\A[0-9a-zA-Z]+\z/, message: 'only allows letters and numbers' }
  validates :target_url, presence: true,
                         format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                   message: 'must be a valid HTTP or HTTPS URL' }
end
