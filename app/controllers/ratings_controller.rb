class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game
  before_action :set_rating, only: [:show, :update, :destroy]

  def create
    @rating = current_user.ratings.build(rating_params.merge(game: @game))

    if @rating.save
      respond_to do |format|
        format.html { redirect_to @game, notice: "Thank you for rating this game!" }
        format.turbo_stream
        format.json { render json: {status: "success", rating: @rating.rating, average: @game.reload.rating_avg} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: "Unable to save your rating." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rating_form_#{@game.id}", partial: "shared/rating_form", locals: {game: @game, rating: @rating}) }
        format.json { render json: {error: @rating.errors.full_messages}, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @rating.update(rating_params)
      respond_to do |format|
        format.html { redirect_to @game, notice: "Your rating has been updated!" }
        format.turbo_stream
        format.json { render json: {status: "updated", rating: @rating.rating, average: @game.reload.rating_avg} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: "Unable to update your rating." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rating_form_#{@game.id}", partial: "shared/rating_form", locals: {game: @game, rating: @rating}) }
        format.json { render json: {error: @rating.errors.full_messages}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @rating.destroy
      respond_to do |format|
        format.html { redirect_to @game, notice: "Your rating has been removed." }
        format.turbo_stream
        format.json { render json: {status: "deleted", average: @game.reload.rating_avg} }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: "Unable to remove your rating." }
        format.turbo_stream
        format.json { render json: {error: "Unable to remove rating"}, status: :unprocessable_entity }
      end
    end
  end

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
    @rating = current_user.ratings.find_by(game: @game)
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
