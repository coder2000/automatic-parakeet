class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :share]
  before_action :set_game, only: [:show, :edit, :update, :destroy, :share]
  def share
    # Renders app/views/games/share.html.erb
  end
  before_action :check_game_owner, only: [:edit, :update, :destroy]

  def indiepad
    settings = IndiepadConfig.defaults
    result = @game.indiepad_config.data.each_with_index.map do |player, _i|
      settings[:default].map do |default_key, _|
        key = player[default_key.to_s]
        [settings[:keycodes][key], settings[:keynames][key]]
      end
    end
    render json: {keys: result}
  end

  def index
    @q = Game.ransack(params[:q])
    @games = @q.result(distinct: true).includes(:genre, :tool, :user).order(created_at: :desc)
    render layout: "application"
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
      redirect_to @game, notice: t("flash.game_created")
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
      redirect_to @game, notice: t("flash.game_updated")
    else
      @genres = Genre.all
      @tools = Tool.all
      @platforms = Platform.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: t("flash.game_deleted")
  end

  private

  def set_game
    @game = Game.friendly.find(params[:id])
  end

  def check_game_owner
    unless @game.user == current_user || current_user.staff?
      flash[:alert] = t("flash.not_authorized")
      redirect_to @game
    end
  end

  def game_params
    permitted_params = params.require(:game).permit(:name, :description, :genre_id, :tool_id, :release_type, :adult_content, :cover_image_id, :author, :long_description, :mobile, :indiepad,
      download_links_attributes: [:id, :url, :file, :_destroy, platform_ids: []],
      media_attributes: [:id, :media_type, :title, :description, :position, :file, :youtube_url, :_destroy],
      game_languages_attributes: [:id, :language_code, :_destroy],
      indiepad_config_attributes: [:id, {data: {}}])

    # Convert empty or invalid cover_image_id to nil to avoid foreign key violations
    if permitted_params[:cover_image_id].blank? || permitted_params[:cover_image_id].to_i == 0
      permitted_params[:cover_image_id] = nil
    end

    permitted_params
  end
end
