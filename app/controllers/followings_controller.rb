class FollowingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game

  def create
    @following = current_user.followings.build(game: @game)
    
    if @following.save
      @following.create_activity(:follow)
      respond_to do |format|
        format.html { redirect_to @game, notice: 'Successfully followed this game!' }
        format.turbo_stream
        format.json { render json: { status: 'followed', followers_count: @game.followings.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: 'Unable to follow this game.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_button_#{@game.id}", partial: 'shared/follow_button', locals: { game: @game }) }
        format.json { render json: { error: @following.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @following = current_user.followings.find_by(game: @game)
    
    if @following&.destroy
      respond_to do |format|
        format.html { redirect_to @game, notice: 'Successfully unfollowed this game!' }
        format.turbo_stream
        format.json { render json: { status: 'unfollowed', followers_count: @game.followings.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: 'Unable to unfollow this game.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_button_#{@game.id}", partial: 'shared/follow_button', locals: { game: @game }) }
        format.json { render json: { error: 'Following not found' }, status: :not_found }
      end
    end
  end

  private

  def set_game
    @game = Game.friendly.find(params[:game_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to games_path, alert: 'Game not found.' }
      format.json { render json: { error: 'Game not found' }, status: :not_found }
    end
  end
end