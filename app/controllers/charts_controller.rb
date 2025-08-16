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

    # Get game IDs first, then load the games with includes to avoid GROUP BY issues
    most_downloaded_game_ids = base_scope.joins(:download_links)
      .group("games.id")
      .order("COUNT(download_links.id) DESC")
      .limit(10)
      .pluck(:id)

    safe_downloaded_game_ids = most_downloaded_game_ids.map(&:to_i)
    if safe_downloaded_game_ids.any?
      order_sql = "array_position(ARRAY[#{safe_downloaded_game_ids.join(",")}]::integer[], games.id)"
      @most_downloaded_games = Game.where(id: safe_downloaded_game_ids)
        .includes(:genre, :tool, :user, :download_links)
        .order(Arel.sql(order_sql))
    else
      @most_downloaded_games = Game.none
    end

    @most_active_games = base_scope.includes(:genre, :tool, :user)
      .order(updated_at: :desc)
      .limit(10)
  end
end
