class ChartsController < ApplicationController
  def index
    @genres = Genre.all.order(:name)
    @selected_genre = params[:genre_id].present? ? Genre.find(params[:genre_id]) : nil

    # Base scope for filtering by genre
    base_scope = @selected_genre ? Game.where(genre: @selected_genre) : Game

    @most_voted_games = base_scope.includes(:genre, :tool, :user)
      .where("rating_count > 0")
      .order(rating_count: :desc, rating_avg: :desc)
      .limit(10)

    @highest_rated_games = base_scope.includes(:genre, :tool, :user)
      .where("rating_count >= 3") # Minimum 3 votes for credibility
      .order(rating_avg: :desc, rating_count: :desc)
      .limit(10)

    @most_downloaded_games = base_scope.includes(:genre, :tool, :user, :download_links)
      .joins(:download_links)
      .group("games.id")
      .order("COUNT(download_links.id) DESC")
      .limit(10)

    @newest_games = base_scope.includes(:genre, :tool, :user)
      .order(created_at: :desc)
      .limit(10)

    @most_active_games = base_scope.includes(:genre, :tool, :user)
      .order(updated_at: :desc)
      .limit(10)
  end
end
