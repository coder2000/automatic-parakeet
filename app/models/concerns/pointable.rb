module Pointable
  extend ActiveSupport::Concern

  included do
    # Add callbacks for models that award points on creation/destruction
    if respond_to?(:after_create) && respond_to?(:after_destroy)
      after_create :award_creation_points, if: :should_award_creation_points?
      after_destroy :remove_creation_points, if: :should_award_creation_points?
    end
  end

  # For User model - point tracking methods
  def total_points
    respond_to?(:score) ? score : 0
  end

  def points_from_activities
    return 0 unless respond_to?(:owned_activities)

    owned_activities.where(key: "points.awarded").sum { |a| a.parameters["points"] || 0 }
  end

  def recent_point_activities(limit = 10)
    return [] unless respond_to?(:owned_activities)

    owned_activities.where(key: ["points.awarded", "points.removed"])
      .order(created_at: :desc)
      .limit(limit)
  end

  private

  def should_award_creation_points?
    # Override in models that should award points
    false
  end

  def award_creation_points
    return unless respond_to?(:user) && user.present?

    point_type = case self.class.name
    when "Game" then :create_game
    when "Comment" then :create_comment
    else return
    end

    PointCalculator.award_points(user, point_type)
  end

  def remove_creation_points
    return unless respond_to?(:user) && user.present?

    point_type = case self.class.name
    when "Game" then :create_game
    when "Comment" then :create_comment
    else return
    end

    PointCalculator.remove_points(user, point_type)
  end
end
