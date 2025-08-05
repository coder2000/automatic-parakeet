# == Schema Information
#
# Table name: download_links
#
#  id         :bigint           not null, primary key
#  label      :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_download_links_on_game_id  (game_id)
#  index_download_links_on_url      (url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#

class DownloadLink < ApplicationRecord
  belongs_to :game
  has_many :downloads, dependent: :destroy

  has_one_attached :file

  has_and_belongs_to_many :platforms

  validates :label, presence: true, length: {maximum: 255}
  validates :url, url: {allow_blank: true}
  validates :url, presence: true, if: -> { file.blank? }
  validates :url, uniqueness: true
  validate :file_or_url_present
  validate :file_size_limit

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[label url created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[game platforms]
  end

  # Scopes
  scope :for_game, ->(game) { where(game: game) }
  scope :for_platform, ->(platform) { joins(:platforms).where(platforms: {id: platform.id}) }

  # Instance methods
  def to_s
    label
  end

  def platform_names
    platforms.pluck(:name).join(", ")
  end

  def download_filename
    # If file is attached, return the filename
    return file.filename.to_s if file.attached?

    # Otherwise, extract filename from URL
    return "" if url.blank?

    uri = URI.parse(url)
    filename = File.basename(uri.path)

    # Remove query parameters if present
    filename = filename.split("?").first

    # Return the path component if no clear filename
    filename.present? ? filename : File.basename(uri.path)
  rescue URI::InvalidURIError
    ""
  end

  private

  def file_or_url_present
    errors.add(:base, "Either file or URL must be present") if file.blank? && url.blank?
  end

  def file_size_limit
    return unless file.attached?

    if file.byte_size > 500.megabytes
      errors.add(:file, "must be less than 500MB")
    end
  end
end
