# Prosopite configuration for N+1 query detection
if defined?(Prosopite)
  Prosopite.rails_logger = true
  Prosopite.enable_instrumentation
  Prosopite.ignore_queries_if = ->(env) { Rails.env.production? }
  # Uncomment to raise exceptions on N+1
  # Prosopite.raise = true
end
