class NewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game
  before_action :set_news, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[new create edit update destroy]

  def new
    @news = @game.news.build
  end

  def create
    @news = @game.news.build(news_params.merge(user: current_user))
    if @news.save
      redirect_to game_path(@game), notice: "News was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_news
    @news = @game.news.find(params[:id]) if params[:id]
  end

  def authorize_user!
    unless @game.user == current_user
      redirect_to game_path(@game), alert: "You are not authorized to add news for this game."
    end
  end

  def news_params
    params.require(:news).permit(:title, :body)
  end
end
