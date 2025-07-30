# frozen_string_literal: true

require "database_cleaner-active_record"

# Configure DatabaseCleaner for proper test isolation
DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.allow_production = false

RSpec.configure do |config|
  config.before(:suite) do
    # Clean the database completely before starting
    DatabaseCleaner.clean_with(:truncation)

    # Set default strategy
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    # Use truncation for tests that need it (system, feature, js tests)
    DatabaseCleaner.strategy = if example.metadata[:type] == :system ||
        example.metadata[:type] == :feature ||
        example.metadata[:js] ||
        example.metadata[:truncation]
      :truncation
    else
      :transaction
    end

    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Special handling for Active Storage and counter caches
  config.after(:each) do
    # Clean up Active Storage attachments that might not be cleaned by transactions
    if Rails.env.test?
      ActiveStorage::Attachment.where.not(
        record_type: [Game, User, Medium].map(&:name)
      ).destroy_all

      ActiveStorage::Blob.left_joins(:attachments)
        .where(active_storage_attachments: { id: nil })
        .destroy_all
    end
  end

  # Reset counter caches for specific tagged tests
  config.after(:each, :reset_counters) do
    Game.reset_counters(Game.pluck(:id), :screenshots, :videos)
    User.reset_counters(User.pluck(:id), :notifications) if User.column_names.include?('notifications_count')
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
