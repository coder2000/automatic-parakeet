# Prosopite configuration for N+1 query detection
if defined?(Prosopite)
  Prosopite.rails_logger = true
  # Use ignore_queries= for recent versions
  Prosopite.ignore_queries = -> { Rails.env.production? }
  # Uncomment to raise exceptions on N+1
  # Prosopite.raise = true
end
