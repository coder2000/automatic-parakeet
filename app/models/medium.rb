# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :integer          default(NULL), not null
#  mediable_type :string           not null
#  position      :integer          default(0)
#  youtube_url   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mediable_id   :bigint           not null
#
# Indexes
#
#  index_media_on_mediable                                    (mediable_type,mediable_id)
#  index_media_on_mediable_type_and_mediable_id_and_position  (mediable_type,mediable_id,position)
#
class Medium < ApplicationRecord
  # Polymorphic association
  belongs_to :mediable, polymorphic: true

  # Active Storage attachment (screenshots only)
  has_one_attached :file do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [400, 225], format: :webp, quality: 80
    attachable.variant :optimized, resize_to_limit: [1920, 1080], format: :webp, quality: 90
  end

  # Counter culture for maintaining count caches
  counter_culture :mediable,
    column_name: proc { |model| model.screenshot? ? "screenshots_count" : nil }

  counter_culture :mediable,
    column_name: proc { |model| model.video? ? "videos_count" : nil }

  # Enums
  enum :media_type, {
    screenshot: 0,
    video: 1
  }, default: :screenshot

  # Validations
  validates :media_type, presence: true
  validates :position, presence: true, numericality: {greater_than_or_equal_to: 0}
  validate :file_content_type, if: :screenshot?
  validate :file_size_limit, if: :screenshot?
  validates :file, presence: true, if: :screenshot?
  validates :youtube_url, presence: true, format: {with: %r{\A(https://(www\.)?youtube\.com/watch\?v=.+|https://youtu\.be/.+)\z}, message: "must be a valid YouTube URL"}, if: :video?

  # Scopes
  scope :ordered, -> { order(:position, :created_at) }
  scope :screenshots, -> { where(media_type: :screenshot) }
  scope :videos, -> { where(media_type: :video) }

  # Callbacks
  before_validation :set_default_position, on: :create

  # Class methods
  def self.ransackable_attributes(auth_object = nil)
    %w[media_type description position created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[mediable]
  end

  private

  def file_content_type
    return unless file.attached?
    unless file.content_type.in?(["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"])
      errors.add(:file, "must be JPEG, PNG, GIF, or WebP format for screenshots")
    end
  end

  def file_size_limit
    return unless file.attached?
    if file.byte_size > 10.megabytes
      errors.add(:file, "must be less than 10MB for screenshots")
    end
  end

  def set_default_position
    return if position.present?
    last_position = mediable&.media&.where(media_type: media_type)&.maximum(:position) || -1
    self.position = last_position + 1
  end
end
