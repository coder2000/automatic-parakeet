class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  private

  # Set locale from params, user, or default
  def set_locale
    I18n.locale = extract_locale_from_params || current_user_locale || I18n.default_locale
  end

  # Extract locale from URL params (e.g., /en/..., /es/...)
  def extract_locale_from_params
    locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
  end

  # Get locale from current_user if available
  def current_user_locale
    current_user&.preferred_locale if respond_to?(:current_user)
  end

  # Ensure locale param is added to all generated URLs
  def default_url_options
    { locale: I18n.locale }
  end
end
