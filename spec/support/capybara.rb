# Capybara configuration for system tests

require "capybara/rails"
require "capybara/rspec"

# Configure Capybara
Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.default_normalize_ws = true
  config.ignore_hidden_elements = true
  config.match = :prefer_exact
  config.exact = false
  config.raise_server_errors = true
  config.visible_text_only = true
end

# Configure Chrome driver for headless testing
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Configure Chrome driver for visible testing (useful for debugging)
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Set default drivers
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configure server
Capybara.server = :puma, {Silent: true}

RSpec.configure do |config|
  # Clean up after each test
  config.after(:each, type: :system) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  # Use transactional fixtures for system tests
  config.use_transactional_fixtures = false

  # Use database cleaner for system tests
  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-enabled tests.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :system, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :system) do
    DatabaseCleaner.start
  end

  # Automatically switch to Selenium for JS/system specs or when driver metadata is set
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
    Capybara.current_driver = Capybara.javascript_driver
  end

  config.before(:each, type: :system) do |example|
    if example.metadata[:driver]
      driven_by example.metadata[:driver]
      Capybara.current_driver = example.metadata[:driver]
    end
  end

  config.append_after(:each, type: :system) do
    DatabaseCleaner.clean
  end
end
