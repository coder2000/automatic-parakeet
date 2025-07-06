# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  adult_content :boolean          default(FALSE)
#  description   :text             not null
#  name          :string           not null
#  rating_abs    :float            default(0.0), not null
#  rating_avg    :float            default(0.0), not null
#  rating_count  :integer          default(0), not null
#  release_type  :integer          default("complete"), not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  genre_id      :bigint
#  tool_id       :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_games_on_genre_id  (genre_id)
#  index_games_on_tool_id   (tool_id)
#  index_games_on_user_id   (user_id)
#
class Game < ApplicationRecord
  enum :release_type, { complete: 0, demo: 1, minigame: 2 }

  # Associations
  belongs_to :user
  belongs_to :genre
  belongs_to :tool
  has_many :download_links, dependent: :destroy

  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true
  validates :description, presence: true
end
