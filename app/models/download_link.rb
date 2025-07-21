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
  validates :url, presence: true, url: {allow_blank: true}
  validate :file_or_url_present

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
end
