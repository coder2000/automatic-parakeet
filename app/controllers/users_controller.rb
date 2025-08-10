class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update, :games, :following, :ratings]
  before_action :ensure_current_user, only: [:edit, :update]

  def show
    @user_games = @user.games.includes(:genre, :tool, :user).limit(12)
    @total_games = @user.games.count
    @total_followers = 0 # Will implement when user following is added
    @join_date = @user.created_at
    @recent_activities = @user.recent_point_activities(5)
    @commented_games =  @user.commented_games.order(created_at: :desc)
  end

  def edit
    # Edit profile form
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def games
    @games = @user.games.includes(:genre, :tool, :user)
      .order(created_at: :desc)
      .limit(24)
  end

  def following
    @followed_games = @user.followed_games.includes(:genre, :tool, :user)
      .order("followings.created_at DESC")
      .limit(24)
  end

  def ratings
    @rated_games = @user.rated_games.includes(:genre, :tool, :user)
      .joins(:ratings)
      .where(ratings: {user: @user})
      .order("ratings.created_at DESC")
      .limit(24)
  end

  private

  def set_user
    @user = User.find_by(username: params[:id]) || User.find_by(id: params[:id])
    unless @user
      redirect_to root_path, alert: "User not found."
      nil
    end
  end

  def ensure_current_user
    unless @user == current_user
      redirect_to @user, alert: "You can only edit your own profile."
    end
  end

  def user_params
    params.require(:user).permit(:given_name, :surname, :phone_number, :locale)
  end
end
