# == Schema Information
#
# Table name: media
#
#  id            :bigint           not null, primary key
#  description   :text
#  media_type    :string           not null
#  mediable_type :string           not null
#  position      :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mediable_id   :bigint           not null
#
# Indexes
#
#  index_media_on_mediable                                      (mediable_type,mediable_id)
#  index_media_on_mediable_type_and_mediable_id_and_media_type  (mediable_type,mediable_id,media_type)
#  index_media_on_mediable_type_and_mediable_id_and_position    (mediable_type,mediable_id,position)
#
class Medium < ApplicationRecord
  # Polymorphic association
  belongs_to :mediable, polymorphic: true

  # Active Storage attachment
  has_one_attached :file

  # Counter culture for maintaining count caches
  counter_culture :mediable,
    column_name: proc { |model| model.screenshot? ? "screenshots_count" : nil }

  counter_culture :mediable,
    column_name: proc { |model| model.video? ? "videos_count" : nil }

  # Enums
  enum :media_type, {
    screenshot: "screenshot",
    video: "video"
  }

  # Validations
  validates :media_type, presence: true
  validates :file, presence: true
  validates :position, presence: true, numericality: {greater_than_or_equal_to: 0}
  validate :file_content_type
  validate :file_size_limit

  # Scopes
  scope :ordered, -> { order(:position, :created_at) }
  scope :screenshots, -> { where(media_type: "screenshot") }
  scope :videos, -> { where(media_type: "video") }

  # Callbacks
  before_validation :set_default_position, on: :create

  # Class methods
  def self.ransackable_attributes(auth_object = nil)
    %w[media_type title description position created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[mediable]
  end

  # Instance methods
  def screenshot?
    media_type == "screenshot"
  end

  def video?
    media_type == "video"
  end

  private

  def file_content_type
    return unless file.attached?

    case media_type
    when "screenshot"
      unless file.content_type.in?(["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"])
        errors.add(:file, "must be JPEG, PNG, GIF, or WebP format for screenshots")
      end
    when "video"
      unless file.content_type.in?(["video/mp4", "video/webm", "video/ogg", "video/avi", "video/mov"])
        errors.add(:file, "must be MP4, WebM, OGG, AVI, or MOV format for videos")
      end
    end
  end

  def file_size_limit
    return unless file.attached?

    case media_type
    when "screenshot"
      if file.byte_size > 10.megabytes
        errors.add(:file, "must be less than 10MB for screenshots")
      end
    when "video"
      if file.byte_size > 100.megabytes
        errors.add(:file, "must be less than 100MB for videos")
      end
    end
  end

  def set_default_position
    return if position.present?

    last_position = mediable&.media&.where(media_type: media_type)&.maximum(:position) || -1
    self.position = last_position + 1
  end
end
