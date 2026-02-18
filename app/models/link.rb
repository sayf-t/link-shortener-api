class Link < ApplicationRecord
  MAX_CODE_LENGTH = 15
  CODE_FORMAT = /\A[0-9a-zA-Z]+\z/

  has_many :click_events, dependent: :destroy

  normalizes :target_url, with: ->(url) { url.to_s.strip }

  validates :short_code, presence: true,
                         uniqueness: { case_sensitive: true },
                         length: { maximum: MAX_CODE_LENGTH },
                         format: { with: CODE_FORMAT, message: "only allows letters and numbers" }
  validates :target_url, presence: true,
                         format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                   message: "must be a valid HTTP or HTTPS URL" }
end
