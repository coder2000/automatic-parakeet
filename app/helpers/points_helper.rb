module PointsHelper
  def point_value_for_action(action)
    PointCalculator.point_value_for(action)
  end

  def format_points(points)
    number_with_delimiter(points)
  end

  def point_action_description(action)
    descriptions = {
      "create_game" => "Created a game",
      "follow_game" => "Followed a game",
      "rate_game" => "Rated a game",
      "post_news" => "Posted news",
      "game_downloaded" => "Game was downloaded",
      "game_rated" => "Game received a rating"
    }

    descriptions[action.to_s] || action.to_s.humanize
  end

  def points_breakdown_for_user(user)
    activities = user.owned_activities.where(key: ["points.awarded", "points.removed"])

    breakdown = Hash.new(0)
    activities.each do |activity|
      action = activity.parameters["action"]
      points = activity.parameters["points"] || 0
      points = -points if activity.key == "points.removed"
      breakdown[action] += points
    end

    breakdown
  end
end
