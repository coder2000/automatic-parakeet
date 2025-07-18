class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def create
    # Prevent users from rating their own games
    if @game.user == current_user
      respond_to do |format|
        format.html { redirect_to @game, alert: t("flash.rating_own_game") }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rating_form_#{@game.id}", partial: "shared/rating_form", locals: {game: @game, rating: nil}) }
        format.json { render json: {error: "You cannot rate your own game"}, status: :forbidden }
      end
      return
    end

    @rating = current_user.ratings.build(rating_params.merge(game: @game))
    if @rating.save
      respond_to do |format|
        format.html { redirect_to @game, notice: t("flash.rating_created") }
        format.turbo_stream
        format.json { render json: {status: "success", rating: @rating.rating, average: @game.reload.rating_avg} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: t("flash.rating_failed") }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rating_form_#{@game.id}", partial: "shared/rating_form", locals: {game: @game, rating: @rating}) }
        format.json { render json: {error: @rating.errors.full_messages}, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/DELETE not supported for ratings

  private

  def set_game
    @game = Game.friendly.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to games_path, alert: "Game not found." }
      format.json { render json: {error: "Game not found"}, status: :not_found }
    end
  end

  def set_rating
    # Find the rating for the current user, game, and id, ensuring user cannot update/destroy others' ratings
    @rating = Rating.find_by(id: params[:id], game_id: @game.id, user_id: current_user.id)
    unless @rating
      respond_to do |format|
        format.html { redirect_to @game, alert: "Rating not found." }
        format.json { render json: {error: "Rating not found"}, status: :not_found }
      end
    end
  end

  def rating_params
    params.require(:rating).permit(:rating)
  end
end
