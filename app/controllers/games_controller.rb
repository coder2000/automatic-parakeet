class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :check_game_owner, only: [:edit, :update, :destroy]

  def index
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true).includes(:genre, :tool, :user).order(created_at: :desc)
  end

  def show
  end

  def new
    @game = current_user.games.build
    @genres = Genre.all
    @tools = Tool.all
    @platforms = Platform.all
  end

  def create
    @game = current_user.games.build(game_params)

    if @game.save
      redirect_to @game, notice: "Game was successfully created."
    else
      @genres = Genre.all
      @tools = Tool.all
      @platforms = Platform.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @genres = Genre.all
    @tools = Tool.all
    @platforms = Platform.all
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: "Game was successfully updated."
    else
      @genres = Genre.all
      @tools = Tool.all
      @platforms = Platform.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: "Game was successfully deleted."
  end

  private

  def set_game
    @game = Game.friendly.find(params[:id])
  end

  def check_game_owner
    unless @game.user == current_user || current_user.staff?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to @game
    end
  end

  def game_params
    params.require(:game).permit(:name, :description, :genre_id, :tool_id, :release_type, :adult_content, :cover_image_id,
      download_links_attributes: [:id, :label, :url, :file, :_destroy, platform_ids: []],
      media_attributes: [:id, :media_type, :title, :description, :position, :file, :_destroy])
  end
end
