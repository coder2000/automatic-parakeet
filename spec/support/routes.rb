RSpec.configure do |config|
  # Include route helpers for all relevant test types
  config.include Rails.application.routes.url_helpers, type: :controller
  config.include Rails.application.routes.url_helpers, type: :integration
  config.include Rails.application.routes.url_helpers, type: :feature
  config.include Rails.application.routes.url_helpers, type: :system
  config.include Rails.application.routes.url_helpers, type: :view

  config.before(:each, type: :request) do
    # Set default locale for route generation in tests
    Rails.application.routes.default_url_options[:locale] = :en
  end

  config.before(:each, type: :controller) do
    Rails.application.routes.default_url_options[:locale] = :en
  end

  config.before(:each, type: :integration) do
    Rails.application.routes.default_url_options[:locale] = :en
  end

  config.before(:each, type: :feature) do
    Rails.application.routes.default_url_options[:locale] = :en
  end

  config.before(:each, type: :system) do
    Rails.application.routes.default_url_options[:locale] = :en
  end

  config.before(:each, type: :view) do
    Rails.application.routes.default_url_options[:locale] = :en
  end
end
