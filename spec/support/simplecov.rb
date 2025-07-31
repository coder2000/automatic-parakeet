# frozen_string_literal: true

require "simplecov"
require "simplecov-cobertura"

SimpleCov.start "rails" do
  # Output formats
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ])

  # Coverage thresholds (starting with realistic targets)
  minimum_coverage 70
  minimum_coverage_by_file 60

  # Directories to track
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services", "app/services"
  add_group "Jobs", "app/jobs"
  add_group "Helpers", "app/helpers"
  add_group "Components", "app/components"
  add_group "Mailers", "app/mailers"
  add_group "Decorators", "app/decorators"
  add_group "Concerns", ["app/controllers/concerns", "app/models/concerns"]

  # Files to exclude from coverage
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/tmp/"
  add_filter "/log/"
  add_filter "/public/"
  add_filter "/node_modules/"
  add_filter "app/channels/application_cable/"
  add_filter "app/jobs/application_job.rb"
  add_filter "app/mailers/application_mailer.rb"
  add_filter "app/models/application_record.rb"
  add_filter "app/controllers/application_controller.rb"

  # Track branches for better coverage
  enable_coverage :branch
  primary_coverage :branch

  # Refuse dropping coverage
  refuse_coverage_drop
end
