# frozen_string_literal: true

# NewsConfig stores staff-configurable settings for News model
class NewsConfig
  # Default cooloff interval in seconds (e.g., 10 minutes)
  DEFAULT_COOLOFF = 10.minutes

  class << self
    # Returns the cooloff interval for news posts
    def cooloff_interval
      Rails.application.config.x.news_cooloff_interval || DEFAULT_COOLOFF
    end

    # Allows staff to set the cooloff interval (in seconds)
    def cooloff_interval=(seconds)
      Rails.application.config.x.news_cooloff_interval = seconds
    end
  end
end
