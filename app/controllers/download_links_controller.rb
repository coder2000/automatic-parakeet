class DownloadLinksController < ApplicationController
  before_action :set_download_link
  before_action :set_game

  def download
    # Check if this is a file download or URL redirect
    if @download_link.file.attached?
      # Create or update download record for analytics
      create_download_record

      # Serve the file with proper headers
      send_data @download_link.file.download,
        filename: @download_link.download_filename,
        type: @download_link.file.content_type || "application/octet-stream",
        disposition: "attachment"
    elsif @download_link.url.present?
      # Create or update download record for analytics
      create_download_record

      # Redirect to external URL
      redirect_to @download_link.url, allow_other_host: true
    else
      # No file or URL available
      redirect_to game_path(@game), alert: "Download not available."
    end
  end

  private

  def set_download_link
    @download_link = DownloadLink.find(params[:id])
  end

  def set_game
    @game = @download_link.game
  end

  def create_download_record
    # Check if user has already downloaded this within the last 10 days to prevent duplicate counting
    existing_download = if user_signed_in?
      Download.where(download_link: @download_link, user: current_user)
        .where("created_at > ?", 10.days.ago)
        .first
    else
      Download.where(download_link: @download_link, ip_address: request.remote_ip)
        .where("created_at > ?", 10.days.ago)
        .first
    end

    if existing_download
      # Update existing download timestamp
      existing_download.touch
    else
      # Create new download record
      Download.create!(
        download_link: @download_link,
        user: current_user,
        ip_address: request.remote_ip,
        count: 1
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    # Log the error but don't block the download
    Rails.logger.warn "Failed to create download record: #{e.message}"
  end
end
