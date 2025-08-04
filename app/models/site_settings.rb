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

  validates :logo_alt_text, presence: true, length: {maximum: 255}
  validates :id, inclusion: {in: ["main"]}
  validate :logo_format, if: -> { logo.attached? }

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
end
