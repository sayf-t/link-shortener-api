source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[windows jruby]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

gem "faraday", "~> 2.14"
gem "geocoder", "~> 1.8"
gem "rack-cors", "~> 3.0"
gem "rack-attack", "~> 6.7"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0"
  gem "rubocop", "~> 1.84"
  gem "rubocop-rspec", "~> 3.9"
end

group :test do
  gem "webmock"
  gem "factory_bot_rails"
end
