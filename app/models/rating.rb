# == Schema Information
#
# Table name: ratings
#
#  id         :bigint           not null, primary key
#  rating     :float            default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ratings_on_game_id              (game_id)
#  index_ratings_on_user_id              (user_id)
#  index_ratings_on_user_id_and_game_id  (user_id,game_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :game

  # Counter cache for rating_count, plus custom average and absolute value
  counter_culture :game,
    column_name: proc { |rating| }, # disables default counter
    delta_column: nil,
    touch: true,
    after_update: true,
    after_destroy: true,
    after_create: true,
    # Custom logic for updating average and absolute value
    custom_counter_cache: ->(rating) {
      game = rating.game
      ratings = game.ratings.reload
      count = ratings.size
      avg = count.positive? ? ratings.average(:rating).to_f : 0.0
      abs = ratings.sum(:rating).to_f
      game.update_columns(rating_count: count, rating_avg: avg, rating_abs: abs)
      nil # disables default counter
    }

  validates :rating, presence: true, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 5}
  validates :user, uniqueness: {scope: :game_id}
  validates :game, presence: true
  validates :user, presence: true
end
