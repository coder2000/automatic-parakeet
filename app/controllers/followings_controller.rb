class FollowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def create
    @following = current_user.followings.build(game: @game)
    @style = style_param

    if @following.save
      @following.create_activity(:follow)
      respond_to do |format|
        format.html { redirect_to @game, notice: t("flash.following_created") }
        format.turbo_stream
        format.json { render json: {status: "followed", followers_count: @game.followings.count} }
      end
    else
      render_error("Unable to follow this game.")
    end
  end

  def destroy
    @following = current_user.followings.find_by(game: @game)
    @style = style_param

    if @following&.destroy
      respond_to do |format|
        format.html { redirect_to @game, notice: t("flash.following_destroyed") }
        format.turbo_stream
        format.json { render json: {status: "unfollowed", followers_count: @game.followings.count} }
      end
    else
      render_error("Unable to unfollow this game.")
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

  def style_param
    (params[:style] || default).to_sym
  end

  def render_error(message)
    respond_to do |format|
      format.html { redirect_to @game, alert: message }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_button_#{@game.id}", partial: "shared/follow_button", locals: {game: @game}) }
      format.json { render json: {error: @following.errors.full_messages}, status: :unprocessable_entity }
    end
  end
end
