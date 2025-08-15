class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:history]

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

    # Fallback to latest games ordered by ranking in the user's language
    if @recommended_games.blank?
      locale_code = if user_signed_in? && current_user.preferred_locale.present?
        current_user.preferred_locale
      else
        I18n.locale.to_s
      end

      lang_scoped = Game.includes(:genre, :tool, :user,
        cover_image: {file_attachment: :blob},
        screenshots: {file_attachment: :blob})
        .joins(:game_languages)
        .where(game_languages: {language_code: locale_code})
        .where("rating_count >= 3")
        .order(rating_avg: :desc, rating_count: :desc, created_at: :desc)
        .distinct
        .limit(6)

      @recommended_games = lang_scoped.to_a

      # If nothing matches user's language, fallback to global highest rated
      if @recommended_games.blank?
        @recommended_games = Game.includes(:genre, :tool, :user,
          cover_image: {file_attachment: :blob},
          screenshots: {file_attachment: :blob})
          .where("rating_count >= 3")
          .order(rating_avg: :desc, rating_count: :desc, created_at: :desc)
          .limit(6)
      end
    end
  end

  def history
    @commented_games = current_user
      .commented_games
      .order("comments.created_at DESC")
      .limit(3).decorate
    @followed_games = current_user
      .followed_games
      .order("followings.created_at DESC")
      .limit(3).decorate
  end

  private
end
