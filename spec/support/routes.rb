RSpec.configure do |config|
  config.before(:each, type: :request) do
    # Set default locale for route generation in tests
    Rails.application.routes.default_url_options[:locale] = :en
  end
end
