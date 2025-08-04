# frozen_string_literal: true

# SiteSettings stores staff-configurable site-wide settings
# This is implemented as a singleton to ensure only one set of settings exists
# == Schema Information
#
# Table name: site_settings
#
#  id            :string           not null, primary key
#  logo_alt_text :string           default("Website Logo"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class SiteSettings < ApplicationRecord
  self.primary_key = :id

  # Attach logo image using Active Storage
  has_one_attached :logo
  
  # Attach carousel images using Active Storage
  has_many_attached :carousel_images

  validates :logo_alt_text, presence: true, length: {maximum: 255}
  validates :id, inclusion: {in: ["main"]}
  validate :logo_format, if: -> { logo.attached? }
  validate :carousel_images_format, if: -> { carousel_images.attached? }
  validate :carousel_images_count

  # Singleton pattern - only allow one instance
  def self.main
    find_or_create_by(id: "main") do |settings|
      settings.logo_alt_text = "Website Logo"
    end
  end

  # Override create to prevent multiple instances
  def self.create(attributes = {})
    if exists?
      raise ActiveRecord::RecordNotUnique, "SiteSettings is a singleton and only one instance is allowed"
    end
    super(attributes.merge(id: "main"))
  end

  def self.create!(attributes = {})
    if exists?
      raise ActiveRecord::RecordNotUnique, "SiteSettings is a singleton and only one instance is allowed"
    end
    super(attributes.merge(id: "main"))
  end

  # Get the logo URL with fallback to default
  def logo_url
    if logo.attached?
      Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true)
    else
      # Fallback to the default logo in assets
      ActionController::Base.helpers.asset_path("logo/logo.png")
    end
  end

  # Check if custom logo is uploaded
  def custom_logo?
    logo.attached?
  end
  
  # Check if carousel images are uploaded
  def carousel_images?
    carousel_images.attached? && carousel_images.any?
  end
  
  # Get carousel images for display
  def carousel_images_for_display
    return [] unless carousel_images.attached?
    carousel_images.limit(5)
  end

  private

  def logo_format
    return unless logo.attached?

    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp", "image/svg+xml"]
    unless acceptable_types.include?(logo.content_type)
      errors.add(:logo, "must be a JPEG, PNG, GIF, WebP, or SVG image")
    end

    # Check file size (max 5MB)
    if logo.byte_size > 5.megabytes
      errors.add(:logo, "must be less than 5MB")
    end
  end
  
  def carousel_images_format
    return unless carousel_images.attached?
    
    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
    
    carousel_images.each_with_index do |image, index|
      unless acceptable_types.include?(image.content_type)
        errors.add(:carousel_images, "Image #{index + 1} must be a JPEG, PNG, GIF, or WebP image")
      end
      
      # Check file size (max 10MB for carousel images since they're larger)
      if image.byte_size > 10.megabytes
        errors.add(:carousel_images, "Image #{index + 1} must be less than 10MB")
      end
    end
  end
  
  def carousel_images_count
    return unless carousel_images.attached?
    
    if carousel_images.count > 5
      errors.add(:carousel_images, "cannot have more than 5 images")
    end
  end
end
