# Service to calculate and award points for different user actions
class PointCalculator
  # Point values for different actions
  POINT_VALUES = {
    create_game: 50,
    follow_game: 5,
    rate_game: 10,
    post_news: 15,
    game_downloaded: 2,
    game_rated: 5
  }.freeze

  def self.award_points(user, action, amount = nil)
    return unless user.present?

    points = amount || POINT_VALUES[action.to_sym]
    return unless points&.positive?

    user.increment!(:score, points)

    # Create activity record for point award
    PublicActivity::Activity.create!(
      trackable: user,
      owner: user,
      key: "points.awarded",
      parameters: {
        action: action.to_s,
        points: points,
        total_score: user.score
      }
    )

    points
  end

  def self.remove_points(user, action, amount = nil)
    return unless user.present?

    points = amount || POINT_VALUES[action.to_sym]
    return unless points&.positive?

    # Don't let score go below 0
    points_to_remove = [points, user.score].min
    user.decrement!(:score, points_to_remove)

    # Create activity record for point removal
    PublicActivity::Activity.create!(
      trackable: user,
      owner: user,
      key: "points.removed",
      parameters: {
        action: action.to_s,
        points: points_to_remove,
        total_score: user.score
      }
    )

    points_to_remove
  end

  def self.point_value_for(action)
    POINT_VALUES[action.to_sym]
  end
end
