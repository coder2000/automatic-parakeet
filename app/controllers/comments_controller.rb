class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :check_comment_owner, only: [:edit, :update, :destroy]

  def index
    # Comments are displayed on the game show page
    redirect_to @game
  end

  def show
    redirect_to @game
  end

  def create
    @comment = @game.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @game, notice: t("comments.created_successfully")
    else
      redirect_to @game, alert: @comment.errors.full_messages.join(", ")
    end
  end

  def edit
    # This could be used for AJAX editing in the future
    respond_to do |format|
      format.html { redirect_to @game }
      format.json { render json: {content: @comment.content} }
    end
  end

  def update
    if @comment.update(comment_params.except(:parent_id))
      redirect_to @game, notice: t("comments.updated_successfully")
    else
      redirect_to @game, alert: @comment.errors.full_messages.join(", ")
    end
  end

  def destroy
    @comment.destroy
    redirect_to @game, notice: t("comments.deleted_successfully")
  end

  private

  def set_game
    @game = Game.friendly.find(params[:game_id])
  end

  def set_comment
    @comment = @game.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end

  def check_comment_owner
    unless @comment.user == current_user || current_user.staff?
      redirect_to @game, alert: t("comments.not_authorized")
    end
  end
end
