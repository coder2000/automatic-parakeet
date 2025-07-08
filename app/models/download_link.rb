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

  has_and_belongs_to_many :platforms

  validates :url, url: {allow_blank: true}
  validate :file_or_url_present

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[label url created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[game platforms]
  end

  private

  def file_or_url_present
    errors.add(:base, "Either file or URL must be present") if file.blank? && url.blank?
  end
end
