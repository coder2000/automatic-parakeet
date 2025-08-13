# RSpec configuration for comprehensive test setup

RSpec.configure do |config|
  # Make Rails route helpers (e.g., games_path) available in relevant spec types
  config.include Rails.application.routes.url_helpers, type: :request
  config.include Rails.application.routes.url_helpers, type: :controller
  config.include Rails.application.routes.url_helpers, type: :view
  config.include Rails.application.routes.url_helpers, type: :system
  config.include Rails.application.routes.url_helpers, type: :feature

  # Ensure a default locale for locale-scoped routes
  config.before(:suite) do
    Rails.application.routes.default_url_options[:locale] ||= :en
    # Also set on controllers so url_options are available in specs
    ActionController::Base.default_url_options[:locale] ||= :en
  end

  # Ensure view specs have a controller with URL context
  config.before(:each, type: :view) do
    controller.request = ActionDispatch::TestRequest.create
    allow(controller).to receive(:default_url_options).and_return({locale: :en})
    allow(view).to receive(:controller).and_return(controller)
  end
  # Use color output
  config.color = true

  # Use documentation format for better readability
  config.default_formatter = "doc" if config.files_to_run.one?

  # Show the slowest examples
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed

  # Filter out examples based on metadata
  config.filter_run_when_matching :focus
  config.run_all_when_everything_filtered = true

  # Disable monkey patching (use expect syntax only)
  config.disable_monkey_patching!

  # Configure warnings
  config.warnings = false

  # Shared examples and contexts
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Example metadata
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Configure test timeouts
  config.around(:each, :timeout) do |example|
    timeout = example.metadata[:timeout] || 30
    Timeout.timeout(timeout) { example.run }
  end

  # Configure test retries for flaky tests
  config.around(:each, :retry) do |example|
    retries = example.metadata[:retry] || 3
    retry_count = 0

    begin
      example.run
    rescue => e
      retry_count += 1
      if retry_count < retries
        puts "Test failed, retrying (#{retry_count}/#{retries}): #{e.message}"
        retry
      else
        raise e
      end
    end
  end

  # Configure memory usage monitoring
  config.before(:suite) do
    puts "Starting test suite with #{RSpec.world.example_count} examples"
  end

  config.after(:suite) do
    puts "Test suite completed"

    # Clean up any remaining test files
    if Rails.env.test?
      temp_dirs = [
        Rails.root.join("tmp", "storage"),
        Rails.root.join("tmp", "test_uploads")
      ]

      temp_dirs.each do |dir|
        FileUtils.rm_rf(dir) if Dir.exist?(dir)
        FileUtils.mkdir_p(dir)
      end
    end
  end

  # Configure specific test types
  config.define_derived_metadata(file_path: %r{/spec/models/}) do |metadata|
    metadata[:type] = :model
  end

  config.define_derived_metadata(file_path: %r{/spec/controllers/}) do |metadata|
    metadata[:type] = :controller
  end

  config.define_derived_metadata(file_path: %r{/spec/requests/}) do |metadata|
    metadata[:type] = :request
  end

  config.define_derived_metadata(file_path: %r{/spec/system/}) do |metadata|
    metadata[:type] = :system
  end

  config.define_derived_metadata(file_path: %r{/spec/features/}) do |metadata|
    metadata[:type] = :feature
  end

  config.define_derived_metadata(file_path: %r{/spec/integration/}) do |metadata|
    metadata[:type] = :integration
  end

  config.define_derived_metadata(file_path: %r{/spec/javascript/}) do |metadata|
    metadata[:type] = :javascript
  end

  # Configure test-specific behaviors
  config.before(:each, type: :system) do
    # Ensure clean browser state
    Capybara.reset_sessions! if defined?(Capybara)
  end

  config.before(:each, type: :controller) do
    # Setup controller test environment
    @request.env["devise.mapping"] = Devise.mappings[:user] if defined?(Devise)
  end

  config.before(:each, type: :feature) do
    # Setup feature test environment
    Capybara.current_driver = :rack_test
  end

  config.before(:each, :js) do
    # Setup JavaScript test environment
    Capybara.current_driver = Capybara.javascript_driver
  end

  # Configure Active Job for tests
  config.before(:each) do
    ActiveJob::Base.queue_adapter = :test if defined?(ActiveJob)
  end

  # Configure ActionMailer for tests
  config.before(:each) do
    ActionMailer::Base.deliveries.clear if defined?(ActionMailer)
  end

  # Configure Active Storage for tests
  config.before(:each) do
    # Use test service for Active Storage
    Rails.application.config.active_storage.service = :test if defined?(ActiveStorage)
  end

  # Configure counter culture for tests
  config.before(:each, :counter_culture) do
    # Ensure counter culture is properly initialized
    CounterCulture.config.counter_cache_name = proc { |model_name| "#{model_name.pluralize}_count" }
  end
end

# Custom matchers for better test readability
RSpec::Matchers.define :have_attached_file do |attachment_name|
  match do |record|
    record.send(attachment_name).attached?
  end

  failure_message do |record|
    "expected #{record.class} to have attached file #{attachment_name}"
  end

  failure_message_when_negated do |record|
    "expected #{record.class} not to have attached file #{attachment_name}"
  end
end

RSpec::Matchers.define :have_media_count do |expected_count|
  match do |game|
    game.media.count == expected_count
  end

  failure_message do |game|
    "expected #{game.name} to have #{expected_count} media items, but had #{game.media.count}"
  end
end

RSpec::Matchers.define :have_screenshots_count do |expected_count|
  match do |game|
    game.screenshots.count == expected_count
  end

  failure_message do |game|
    "expected #{game.name} to have #{expected_count} screenshots, but had #{game.screenshots.count}"
  end
end

RSpec::Matchers.define :have_videos_count do |expected_count|
  match do |game|
    game.videos.count == expected_count
  end

  failure_message do |game|
    "expected #{game.name} to have #{expected_count} videos, but had #{game.videos.count}"
  end
end

RSpec::Matchers.define :be_valid_media_type do |media_type|
  match do |medium|
    medium.media_type == media_type && medium.valid?
  end

  failure_message do |medium|
    "expected #{medium} to be valid #{media_type} media type"
  end
end
