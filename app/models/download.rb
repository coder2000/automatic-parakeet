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

  after_create_commit :update_stats

  private

  def unique_ip_for_anonymous!
    return unless user.nil?

    if Download.where(ip_address: ip_address, download_link: download_link, "created_at > ?": 10.days.ago).exists?
      errors.add(:ip_address, "has already downloaded this game")
    end
  end

  def update_stats
    Stat.create_or_increment!(game.id, downloads: count)
  end
end
