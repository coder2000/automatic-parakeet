# == Schema Information
#
# Table name: downloads
#
#  id               :bigint           not null, primary key
#  count            :integer          default(0)
#  ip_address       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  download_link_id :bigint
#  user_id          :bigint
#
# Indexes
#
#  index_downloads_on_download_link_id  (download_link_id)
#  index_downloads_on_user_id           (user_id)
#

class Download < ApplicationRecord
  belongs_to :download_link
  has_one :game, through: :download_link
  belongs_to :user, optional: true

  validate :unique_ip_for_anonymous!

  after_create_commit :update_stats, :award_download_points

  # Scopes
  scope :anonymous, -> { where(user: nil) }
  scope :authenticated, -> { where.not(user: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_game, ->(game) { joins(:download_link).where(download_links: {game: game}) }

  # Instance methods
  def anonymous?
    user.nil?
  end

  def to_s
    if anonymous?
      "Anonymous download of #{download_link.label} from #{ip_address}"
    else
      "Download of #{download_link.label} by #{user.email}"
    end
  end

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[count ip_address created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user download_link game]
  end

  private

  def unique_ip_for_anonymous!
    return unless user.nil?
    return if ip_address.blank? || download_link_id.blank?

    # Only check for downloads with the same IP and download_link in the last 10 days, excluding self (for updates)
    existing = Download.where(ip_address: ip_address, download_link_id: download_link_id)
      .where("created_at > ?", 10.days.ago)
      .where.not(id: id)
    if existing.exists?
      errors.add(:ip_address, "has already downloaded this game")
    end
  end

  def update_stats
    Stat.create_or_increment!(game.id, downloads: count)
  end

  def award_download_points
    # Award points to the game owner for each download
    PointCalculator.award_points(game.user, :game_downloaded)
  end
end
