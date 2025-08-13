class OverlaysController < ApplicationController

  ALLOWED = {
    "dashboard"   => "overlays/dashboard",
    "share"       => "overlays/share
  }.freeze

  def show
    name = params[:id].to_s
    partial_path = ALLOWED[name]
    return head :not_found unless partial_path

    if auth_required?(name) && !user_signed_in?
      #redirect if not logged
      return render partial: "overlays/unauthorized", status: :unauthorized
    end

    # Biggest queries
    case name
    when "dashboard"
      @profile = current_user if user_signed_in?
    # "share" → nessuna query protetta
    end

    render partial: partial_path, formats: [:html]
  end

  private

  # login required
  def auth_required?(name)
    %w[dashboard].include?(name)
  end
end
