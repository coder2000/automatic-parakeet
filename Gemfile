source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Track visits and events in Rails apps
gem "ahoy_matey"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
# Counter Culture for advanced counter caches
gem "counter_culture"

# View components
gem "view_component"

# Hotwire: Turbo and Stimulus for modern Rails interactivity
gem "turbo-rails"
gem "stimulus-rails"

gem "importmap-rails"

gem "dartsass-rails"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "annotaterb"

  gem "rspec-rails", "~> 8.0"
  gem "faker", "~> 3.5"
  gem "factory_bot_rails", "~> 6.5"
  gem "rails-controller-testing"
  gem "capybara"

  gem "prosopite"
  # Shoulda Matchers for RSpec
  gem "shoulda-matchers", "~> 6.0"
  # Database cleaning for test isolation
  gem "database_cleaner-active_record"

  gem "selenium-webdriver"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "better_errors"
  gem "binding_of_caller"
end

gem "letter_opener"

gem "devise", "~> 4.9"

# Admin framework for Rails [https://activeadmin.info/]
gem "activeadmin", "~> 4.0.0.beta"

# Track changes and activities on models [https://github.com/chaps-io/public_activity]
gem "public_activity"

# Slugging and permalinks
gem "friendly_id", "~> 5.5"

# Validate URLs
gem "validate_url"

# Search functionality
gem "ransack"
