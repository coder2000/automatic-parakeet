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

  # Use callbacks to update game rating statistics
  after_save :update_game_rating_stats
  after_destroy :update_game_rating_stats_on_destroy

  # Callbacks for point calculation
  after_create :award_rating_points, :award_game_owner_points
  after_destroy :remove_rating_points, :remove_game_owner_points

  validates :rating, presence: true, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 5}
  validates :user, uniqueness: {scope: :game_id}
  validates :game, presence: true
  validates :user, presence: true

  # Define searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[rating created_at updated_at]
  end

  # Define searchable associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[user game]
  end

  private

  def update_game_rating_stats
    return unless game

    # Calculate new statistics
    ratings = game.ratings.reload
    count = ratings.size
    avg = count.positive? ? ratings.average(:rating).to_f : 0.0
    abs = ratings.sum(:rating).to_f

    # Update game statistics
    game.update_columns(
      rating_count: count,
      rating_avg: avg,
      rating_abs: abs
    )
  end

  def update_game_rating_stats_on_destroy
    target_game = game
    return unless target_game

    # Calculate new statistics (this rating will be excluded since we're in after_destroy)
    remaining_ratings = target_game.ratings.where.not(id: id)
    count = remaining_ratings.size
    avg = count.positive? ? remaining_ratings.average(:rating).to_f : 0.0
    abs = remaining_ratings.sum(:rating).to_f

    # Update game statistics
    target_game.update_columns(
      rating_count: count,
      rating_avg: avg,
      rating_abs: abs
    )
  rescue ActiveRecord::RecordNotFound
    # Game was deleted, nothing to update
    nil
  end

  def award_rating_points
    # Award points to the user who rated
    PointCalculator.award_points(user, :rate_game)
  end

  def award_game_owner_points
    # Award points to the game owner for receiving a rating
    PointCalculator.award_points(game.user, :game_rated)
  end

  def remove_rating_points
    # Remove points from the user who rated
    PointCalculator.remove_points(user, :rate_game)
  end

  def remove_game_owner_points
    # Remove points from the game owner for losing a rating
    PointCalculator.remove_points(game.user, :game_rated)
  end
end
