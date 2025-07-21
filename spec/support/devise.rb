RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Warden::Test::Helpers
  
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
  
  config.before(:suite) do
    # Ensure Devise mappings are loaded
    Rails.application.reload_routes!
  end
  
  config.after(:each) do
    Warden.test_reset!
  end
end
