class HomeController < ApplicationController
  def index
    # Get site settings for carousel images
    @site_settings = SiteSettings.main

    @newest_games = Game.includes(:genre, :tool, :user,
      cover_image: {file_attachment: :blob},
      screenshots: {file_attachment: :blob})
      .order(created_at: :desc)
      .limit(10)

    # Get recommended games (highest rated with minimum credibility)
    @recommended_games = Game.includes(:genre, :tool, :user,
      cover_image: {file_attachment: :blob},
      screenshots: {file_attachment: :blob})
      .where("rating_count >= 3") # Minimum 3 votes for credibility
      .order(rating_avg: :desc, rating_count: :desc)
      .limit(6)
  end

  private
end
