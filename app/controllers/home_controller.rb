class HomeController < ApplicationController
  def index
    # Get site settings for carousel images
    @site_settings = SiteSettings.main

    @newest_games = Game.includes(:genre, :tool, :user,
      cover_image: {file_attachment: :blob},
      screenshots: {file_attachment: :blob})
      .order(created_at: :desc)
      .limit(10)

    # Personalized recommendations using Disco based on followings.
    @recommended_games = []
    if user_signed_in?
      recommender = Recommendations::DiscoRecommender.new
      ids = recommender.recommendations_for(current_user.id, limit: 6)
      if ids.present?
        @recommended_games = Game.includes(:genre, :tool, :user,
          cover_image: {file_attachment: :blob},
          screenshots: {file_attachment: :blob})
          .where(id: ids)
          .index_by(&:id)
        # Keep the order provided by the recommender
        @recommended_games = ids.map { |id| @recommended_games[id] }.compact
      end
    end

    # Fallback to highest rated with minimum credibility
    if @recommended_games.blank?
      @recommended_games = Game.includes(:genre, :tool, :user,
        cover_image: {file_attachment: :blob},
        screenshots: {file_attachment: :blob})
        .where("rating_count >= 3")
        .order(rating_avg: :desc, rating_count: :desc)
        .limit(6)
    end
  end

  private
end
