module ApplicationHelper
  # Helper method to access site settings
  def site_settings
    @site_settings ||= SiteSettings.main
  end

  # Helper method to get the site logo URL
  def site_logo_url
    site_settings.logo_url
  end

  # Helper method to get the site logo alt text
  def site_logo_alt_text
    site_settings.logo_alt_text
  end
end
