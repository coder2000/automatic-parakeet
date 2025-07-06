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

  has_one_attached :file

  validates :url, url: { allow_blank: true }
  validate :file_or_url_present

  private

  def file_or_url_present
    errors.add(:base, "Either file or URL must be present") if file.blank? && url.blank?
  end
end
