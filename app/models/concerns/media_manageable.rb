module MediaManageable
  extend ActiveSupport::Concern

  included do
    # Callbacks to auto-set cover image
    before_save :auto_set_cover_image
    after_save :auto_set_cover_image_after_save

    # Media validation
    validate :media_limits
    validate :cover_image_must_be_screenshot
  end

  private

  def media_limits
    # Use counter cache for existing records, count new ones manually
    screenshot_count = screenshots_count || 0
    video_count = videos_count || 0

    # Add counts from new records being added (not yet persisted)
    media.each do |m|
      next if m.persisted? || m.marked_for_destruction?

      if m.screenshot?
        screenshot_count += 1
      elsif m.video?
        video_count += 1
      end
    end

    validate_screenshot_limit(screenshot_count)
    validate_video_limit(video_count)
  end

  def validate_screenshot_limit(count)
    if count > 6
      errors.add(:media, "can't have more than 6 screenshots")
    end
  end

  def validate_video_limit(count)
    if count > 3
      errors.add(:media, "can't have more than 3 videos")
    end
  end

  def cover_image_must_be_screenshot
    return unless cover_image.present?

    unless cover_image.screenshot?
      errors.add(:cover_image, "must be a screenshot")
    end

    unless cover_image.mediable == self
      errors.add(:cover_image, "must belong to this game")
    end
  end

  def auto_set_cover_image
    # If no cover image is set and we have existing screenshots, set the first one as cover
    if cover_image_id.blank? && screenshots.any?
      first_screenshot = screenshots.first
      self.cover_image_id = first_screenshot.id if first_screenshot.present?
    end
  end

  def auto_set_cover_image_after_save
    # After save, if no cover image is set but we now have screenshots (including newly created ones), set the first one
    if cover_image_id.blank?
      screenshots.reload # Ensure we get the latest screenshots
      if screenshots.any?
        first_screenshot = screenshots.first
        update_column(:cover_image_id, first_screenshot.id) if first_screenshot.present?
      end
    end
  end
end
