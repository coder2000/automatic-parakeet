require "resolv"
require "ipaddr"

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

      # Redirect to external URL with security validation
      if safe_redirect_url?(@download_link.url)
        redirect_to @download_link.url, allow_other_host: true
      else
        Rails.logger.warn "Blocked potentially unsafe redirect to: #{@download_link.url}"
        redirect_to game_path(@game), alert: "Download link is not accessible."
      end
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

  def safe_redirect_url?(url)
    return false if url.blank?

    begin
      uri = URI.parse(url)

      # Only allow HTTP and HTTPS schemes
      return false unless %w[http https].include?(uri.scheme&.downcase)

      # Block localhost, private IPs, and loopback addresses to prevent SSRF
      return false if uri.host.nil?

      # Resolve the hostname to check for private/local addresses
      resolved_ip = Resolv.getaddress(uri.host)
      ip_addr = IPAddr.new(resolved_ip)

      # Block private, loopback, and multicast addresses
      return false if ip_addr.private? || ip_addr.loopback?

      # Block known localhost variants
      localhost_patterns = [
        /^localhost$/i,
        /^127\./,
        /^::1$/,
        /^0\.0\.0\.0$/
      ]
      return false if localhost_patterns.any? { |pattern| uri.host.match?(pattern) }

      # Optional: Add allowlist of trusted domains
      # Uncomment and customize based on your trusted download sources
      # trusted_domains = [
      #   'github.com',
      #   'gitlab.com',
      #   'sourceforge.net',
      #   'drive.google.com',
      #   'dropbox.com'
      # ]
      # return trusted_domains.any? { |domain| uri.host.end_with?(domain) }

      true
    rescue URI::InvalidURIError, Resolv::ResolvError, IPAddr::InvalidAddressError => e
      Rails.logger.warn "Invalid URL for download redirect: #{url} - #{e.message}"
      false
    end
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
