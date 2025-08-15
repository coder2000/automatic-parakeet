class OverlaysController < ApplicationController
  ALLOWED = {
    "dashboard" => "overlays/dashboard",
    "share" => "overlays/share"
  }.freeze

  def show
    name = params[:id].to_s
    partial_path = ALLOWED[name]
    return head :not_found unless partial_path

    if auth_required?(name) && !user_signed_in?
      @name = name
      @partial_path = "overlays/unauthorized"
      return render :show, status: :unauthorized
    end

    # Big Queries
    case name
    when "dashboard"
      @profile = current_user if user_signed_in?
    end

    @name = name
    @partial_path = partial_path
    render :show
  end

  private

  def auth_required?(name)
    %w[dashboard].include?(name)
  end
end
